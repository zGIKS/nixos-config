{ pkgsUnstable, ... }:

let
  discord = import ./discord.nix { inherit pkgsUnstable; };
  zed = import ./zed.nix { inherit pkgsUnstable; };
in
{
  default = final: prev:
    (discord final prev) // (zed final prev);
}
