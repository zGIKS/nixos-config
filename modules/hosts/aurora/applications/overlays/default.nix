{ pkgsUnstable, ... }:

{
  default = final: prev:
    (import ./vscode.nix { inherit pkgsUnstable; } final prev)
    // (import ./discord.nix { inherit pkgsUnstable; } final prev);
}
