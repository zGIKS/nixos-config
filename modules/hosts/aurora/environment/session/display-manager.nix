{ pkgs, ... }:

{
  services.xserver.enable = true;
  services.displayManager.sddm.enable = false;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd sway";
        user = "greeter";
      };
    };
  };
}
