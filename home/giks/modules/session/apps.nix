{ config, lib, pkgs, pomodog, roles, ... }:

let
  cfg = config.myHome.apps;
in
{
  options.myHome.apps = {
    base.enable = lib.mkEnableOption "base desktop applications" // {
      default = lib.elem "desktop" roles;
    };
    browsers.enable = lib.mkEnableOption "web browsers" // {
      default = lib.elem "desktop" roles;
    };
    media.enable = lib.mkEnableOption "media and chat desktop applications" // {
      default = lib.elem "desktop" roles;
    };
    documents.enable = lib.mkEnableOption "document and archive desktop applications" // {
      default = lib.elem "desktop" roles;
    };
    devGui.enable = lib.mkEnableOption "heavy GUI development applications" // {
      default = false;
    };
    devTools.enable = lib.mkEnableOption "development desktop applications" // {
      default = lib.elem "dev" roles;
    };
    kimi.enable = lib.mkEnableOption "Kimi Code CLI" // {
      default = lib.elem "dev" roles;
    };
  };

  config.home.sessionPath = lib.optionals cfg.kimi.enable [
    "$HOME/.local/bin"
  ];

  config.home.activation.installKimiCli = lib.mkIf cfg.kimi.enable (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -x "$HOME/.local/bin/kimi" ]; then
        $DRY_RUN_CMD ${pkgs.uv}/bin/uv tool install --python ${pkgs.python313}/bin/python3.13 kimi-cli
      fi
    ''
  );

  config.home.packages = with pkgs;
    [
      pomodog.packages.${pkgs.system}.default
    ]
    ++ lib.optionals cfg.base.enable [
      brightnessctl
      grim
      gsimplecal
      xfce.thunar
      pavucontrol
      playerctl
      slurp
      sway-contrib.grimshot
      swappy
      wdisplays
      yazi
      wl-clipboard
      wofi
      kdePackages.ark
    ]
    ++ lib.optionals cfg.browsers.enable [
      brave
      google-chrome
    ]
    ++ lib.optionals cfg.media.enable [
      discord
      mpv
      obs-studio
      rustdesk-flutter
      spotify
    ]
    ++ lib.optionals cfg.documents.enable [
      typora
    ]
    ++ lib.optionals cfg.devGui.enable [
      jetbrains.datagrip
      android-studio
    ]
    ++ lib.optionals cfg.devTools.enable [
      vscode
      zed-editor
      zellij
    ]
    ++ lib.optionals cfg.kimi.enable [
      python313
      uv
    ];
}
