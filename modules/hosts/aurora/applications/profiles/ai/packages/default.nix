# AI coding CLIs.
#
# Derivations vendored from https://github.com/09641061/airi and maintained in
# this repository. Each one fetches the tool's official prebuilt release;
# packages/<tool>/update.sh refreshes its version and hash.
{ pkgs }:

{
  claude-code = pkgs.callPackage ./claude { inherit pkgs; };
  codex = pkgs.callPackage ./codex { inherit pkgs; };
  antigravity-cli = pkgs.callPackage ./antigravity { inherit pkgs; };
  pi-coding-agent = pkgs.callPackage ./pi { inherit pkgs; };
  herdr = pkgs.callPackage ./herdr { inherit pkgs; };
}
