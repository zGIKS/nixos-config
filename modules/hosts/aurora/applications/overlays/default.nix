{ pkgsUnstable, ... }:

let
  zed = import ./zed.nix { inherit pkgsUnstable; };
in
{
  default = final: prev:
    zed final prev;
}
