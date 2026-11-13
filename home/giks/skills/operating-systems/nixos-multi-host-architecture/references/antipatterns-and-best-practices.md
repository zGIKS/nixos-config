# Official Nix Antipatterns and Best Practices (nix.dev)

This reference documents the 8 core antipatterns identified by official documentation (`nix.dev` and the Nix/Nixpkgs manuals) that must be avoided in scalable multi-host architectures.

---

## 1. Avoid Wide `with pkgs;` (Pattern 9.1)

### The Anti-Pattern
Placing `with pkgs;` at the top of a module or file header:
```nix
# BAD: Injects thousands of package names into the file's lexical scope
{ config, lib, pkgs, ... }:

with pkgs;
{
  environment.systemPackages = [ ripgrep fd git ];
  # Which 'version' or 'name' is this? A local variable or pkgs.version?
}
```

### Why it is harmful
1. **Namespace Pollution**: Nixpkgs defines over 80,000 attributes. Any attribute name might shadow or be shadowed by module arguments, local `let` bindings, or `lib` functions.
2. **Obscure Evaluation Errors**: Misspelled identifiers or renamed packages fail at runtime with confusing error locations rather than static lookup failures.
3. **Unclear Diff Reviews**: Reviewers cannot easily determine whether a reference refers to a package, a function argument, or a local definition.

### Canonical Best Practice
- Use explicit attribute access: `[ pkgs.ripgrep pkgs.fd pkgs.git ]`.
- Confine `with pkgs;` strictly to narrow, localized expressions with clear intent:
  ```nix
  buildInputs = with pkgs; [ openssl zlib libuv ];
  ```
- Or use `inherit`:
  ```nix
  let
    inherit (pkgs) ripgrep fd git;
  in
  [ ripgrep fd git ]
  ```

---

## 2. Avoid Ambient `<nixpkgs>` and `NIX_PATH` in Flakes (Pattern 9.2)

### The Anti-Pattern
Relying on angle-bracket syntax `<nixpkgs>` or `<nixos-config>` inside a flake-managed codebase:
```nix
# BAD: Non-reproducible ambient dependency
let
  pkgs = import <nixpkgs> { };
in ...
```

### Why it is harmful
Angle brackets look up paths in the host machine's mutable environment variable `$NIX_PATH`. Different machines or users will evaluate against completely different package sets, destroying flake hermeticity and reproducibility.

### Canonical Best Practice
Always access `nixpkgs` and other dependencies explicitly through pinned flake `inputs`:
```nix
# GOOD: Fully hermetic, deterministic, and pinned by flake.lock
outputs = { self, nixpkgs, ... }@inputs: {
  nixosConfigurations.srv = nixpkgs.lib.nixosSystem { ... };
};
```

---

## 3. Avoid `rec { ... }` in Attribute Sets (Pattern 9.3)

### The Anti-Pattern
Using recursive attribute sets `rec { ... }`:
```nix
# BAD: Fragile recursion in attribute sets
rec {
  version = "1.0.0";
  url = "https://example.com/app-${version}.tar.gz";
}
```

### Why it is harmful
1. **Broken Overriding**: When an attribute set is modified via `//` or `overrideAttrs`, references within `rec` still resolve to the original, unmodified values, breaking customization.
2. **Scope Traps**: `rec` introduces subtle scoping bugs where attributes shadow outer variables unpredictably.

### Canonical Best Practice
Use standard `let ... in` bindings for shared or intermediate variables:
```nix
# GOOD: Explicit scope and override-safe
let
  version = "1.0.0";
in
{
  inherit version;
  url = "https://example.com/app-${version}.tar.gz";
}
```

---

## 4. Avoid Import From Derivation (IFD) on Critical Paths (Pattern 9.4)

### The Anti-Pattern
Using the output of a derivation as a Nix expression inside `import`:
```nix
# BAD: Import From Derivation
let
  generatedExpr = pkgs.runCommand "gen.nix" { } "echo '{ a = 1; }' > $out";
in
import generatedExpr
```

### Why it is harmful
IFD forces the Nix evaluator to halt, build the intermediate derivation, read the result back from disk, and resume evaluation. This:
- Breaks continuous integration platforms like Hydra and distributed evaluation.
- Significantly slows down `nix flake check` and editor language servers.

### Canonical Best Practice
Keep configuration data as native Nix attribute sets, or generate files at build/runtime rather than during evaluation. Use `pkgs.formats` for structured serialization.

---

## 5. Avoid Unquoted URLs and Bare `src = ./.` (Pattern 9.5)

### The Anti-Pattern
1. Writing bare URLs without quotes: `url = http://example.com;` (deprecated syntax in modern Nix).
2. Setting `src = ./.` without filtering:
```nix
# BAD: Copies entire repository into /nix/store
stdenv.mkDerivation {
  pname = "tool";
  version = "0.1";
  src = ./.; # Copies .git, temporary files, editor backups, and secrets!
}
```

### Why it is harmful
Bare `src = ./.` copies your entire directory tree into the Nix store. Any change to a README, git commit history, or temp file invalidates the derivation hash, forcing needless rebuilds and polluting the store.

### Canonical Best Practice
- Always quote URLs: `url = "https://example.com";`.
- Filter source directories using `lib.cleanSource` or `builtins.path`:
  ```nix
  src = lib.cleanSource ./.;
  # Or with explicit filtering:
  src = lib.cleanSourceWith {
    src = ./.;
    filter = path: type:
      let base = baseNameOf path;
      in base != ".git" && !lib.hasSuffix ".md" base;
  };
  ```

---

## 6. Avoid Implicit Nixpkgs Configuration (Pattern 9.6)

### The Anti-Pattern
Relying on ambient or implicit Nixpkgs configuration like `~/.config/nixpkgs/config.nix` or environment variables for package evaluations.

### Canonical Best Practice
Declare package configuration explicitly within the host's NixOS module hierarchy:
```nix
nixpkgs.config = {
  allowUnfree = true;
  # Or targeted permission:
  allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "steam" "nvidia-x11" ];
};
```

---

## 7. Avoid Shallow `//` on Nested Sets (Pattern 9.7)

### The Anti-Pattern
Using the shallow update operator `//` to merge nested attribute sets:
```nix
# BAD: Shallow update clobbers sibling options!
baseConfig // {
  services = {
    nginx.enable = true; # Completely erases any existing baseConfig.services.sshd!
  };
}
```

### Why it is harmful
The Nix update operator `//` only operates on the top level. When merging nested sets, all unmentioned nested keys are obliterated.

### Canonical Best Practice
- Rely on the NixOS module system's automatic recursive merging: define separate modules and let the module system merge them.
- If merging raw attrsets in pure Nix code, use `lib.recursiveUpdate`:
  ```nix
  lib.recursiveUpdate baseConfig {
    services.nginx.enable = true;
  }
  ```

---

## 8. Avoid Flake Evaluation Impurities (Pattern 9.8)

### The Anti-Pattern
Attempting to read environment variables (`builtins.getEnv`) or files not tracked by Git inside flake evaluation:
```nix
# BAD: Fails in pure flake evaluation
let
  user = builtins.getEnv "USER";
in ...
```

### Why it is harmful
Flakes enforce pure evaluation by default. Uncommitted files or system environment variables are inaccessible. Bypassing this with `--impure` undermines reproducible infrastructure management across a multi-host fleet.

### Canonical Best Practice
Pass host facts, roles, and environment settings declaratively through host composition modules and `_module.args`. Never rely on ambient host state during evaluation.
