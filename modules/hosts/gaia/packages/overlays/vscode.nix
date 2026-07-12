{ pkgsUnstable, ... }:

final: prev: {
  vscode = pkgsUnstable.vscode;
  vscode-fhs = pkgsUnstable.vscode-fhs;
}
