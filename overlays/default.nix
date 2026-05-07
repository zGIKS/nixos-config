{ pkgsUnstable, ... }:

{
  default = final: prev: {
    vscode = pkgsUnstable.vscode;
    vscode-fhs = pkgsUnstable.vscode-fhs;
    zed-editor = pkgsUnstable.zed-editor;
  };
}
