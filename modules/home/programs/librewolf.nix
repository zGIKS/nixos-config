{ lib, pkgs, ... }:

{
  programs.librewolf = {
    enable = true;
    # Configuración para persistir datos y mejorar usabilidad
    settings = {
      "privacy.sanitize.sanitizeOnShutdown" = false;
      "privacy.clearOnShutdown.history" = false;
      "privacy.clearOnShutdown.cookies" = false;
      "privacy.clearOnShutdown.sessions" = false;
      "privacy.clearOnShutdown.downloads" = false;
      "privacy.clearOnShutdown.cache" = false;
      "privacy.clearOnShutdown.formdata" = false;
      "privacy.clearOnShutdown.offlineApps" = false;
      "privacy.clearOnShutdown.siteSettings" = false;
      "network.cookie.lifetimePolicy" = 0;
      # Habilitar WebGL y asegurar compatibilidad
      "webgl.disabled" = false;
      "privacy.resistFingerprinting" = false; # Necesario para WebGL completo y detección de Dark Mode del sistema
      # Opcional: Recordar contraseñas si lo prefieres
      "signon.rememberSignons" = true;
    };
  };
}
