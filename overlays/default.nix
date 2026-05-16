{ pkgsUnstable, ... }:

{
  default = final: prev: {
    discord-ptb = pkgsUnstable.discord-ptb;
    vscode = pkgsUnstable.vscode;
    vscode-fhs = pkgsUnstable.vscode-fhs;
    zed-editor = pkgsUnstable.zed-editor;
  };
}
