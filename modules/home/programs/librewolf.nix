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
      # Forzar modo oscuro y sincronizar con el sistema
      "ui.systemUsesDarkTheme" = 1;
      "layout.css.prefers-color-scheme.content-override" = 2; # 2 = Seguir el esquema de color del sistema
      "privacy.resistFingerprinting" = false; # Necesario para WebGL completo y detección de Dark Mode del sistema
      # Opcional: Recordar contraseñas si lo prefieres
      "signon.rememberSignons" = true;
    };
  };

  home.sessionVariables = {
    BROWSER = "librewolf";
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "librewolf.desktop";
      "application/xhtml+xml" = "librewolf.desktop";
      "x-scheme-handler/http" = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
    };
  };
}
