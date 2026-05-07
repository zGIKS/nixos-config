{ pkgs, ... }:

{
  gtk = {
    enable = true;

    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    cursorTheme = {
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
    };

    font = {
      name = "JetBrainsMono Nerd Font";
      size = 12;
    };

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

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  home.sessionVariables = {
    GTK_THEME = "adw-gtk3-dark";
    COLORTERM = "truecolor";
  };

  home.pointerCursor = {
    gtk.enable = true;
    x11.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Ice";
    size = 24;
  };
}
