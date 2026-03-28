{ pkgs, ... }:

{
  # 1. Aplicar el tema a las aplicaciones GTK (Gnome, etc.)
  gtk = {
    enable = true;
    
    # Usamos adw-gtk3-dark porque es el que mejor aplica colores planos (estilo Zinc)
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    # Iconos minimalistas
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    # Cursor blanco moderno (Ice) para resaltar sobre el fondo oscuro
    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 11;
    };

    # Forzamos tus colores exactos de Waybar mediante CSS de GTK
    # @define-color theme_bg_color #0a0a0c; -> Fondo de ventanas (Zinc 950)
    # @define-color theme_fg_color #fafafa; -> Texto principal (Zinc 50)
    gtk3.extraCss = ''
      @define-color theme_bg_color #0a0a0c;
      @define-color theme_fg_color #fafafa;
      @define-color theme_base_color #0a0a0c;
      @define-color theme_text_color #fafafa;
      @define-color theme_selected_bg_color #fafafa;
      @define-color theme_selected_fg_color #0a0a0c;
      @define-color borders #27272a;
    '';
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
    
    gtk4.extraCss = ''
      @define-color theme_bg_color #0a0a0c;
      @define-color theme_fg_color #fafafa;
      @define-color theme_base_color #0a0a0c;
      @define-color theme_text_color #fafafa;
      @define-color theme_selected_bg_color #fafafa;
      @define-color theme_selected_fg_color #0a0a0c;
      @define-color borders #27272a;
    '';
    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
    };
  };

  # Forzar el esquema de color oscuro a nivel de dconf (necesario para apps modernas y portales)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # 2. Aplicar el tema a las aplicaciones Qt (KDE, VLC, etc.)
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # 3. Forzar el modo oscuro en variables de entorno
  home.sessionVariables = {
    GTK_THEME = "adw-gtk3-dark";
    COLORTERM = "truecolor";
  };

  # 4. Asegurar que el cursor se aplique en todo el sistema (Sway)
  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };
}
