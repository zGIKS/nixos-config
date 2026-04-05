set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx VOLTA_HOME $HOME/.volta
set -gx BUN_INSTALL $HOME/.bun
if test -z "$LIBCLANG_PATH"; and test -e /usr/lib/libclang.so
    set -gx LIBCLANG_PATH /usr/lib
end

# Build a deterministic PATH with stable priority and no duplicates.
set -l preferred_paths \
    $VOLTA_HOME/bin \
    $HOME/.local/bin \
    $BUN_INSTALL/bin \
    $HOME/.cargo/bin \
    $HOME/go/bin

set -l merged_paths
for p in $preferred_paths $PATH
    if test -n "$p"; and not contains -- $p $merged_paths
        set merged_paths $merged_paths $p
    end
end

if test -d "$HOME/.spicetify"; and not contains -- $HOME/.spicetify $merged_paths
    set merged_paths $merged_paths $HOME/.spicetify
end

set -gx PATH $merged_paths

alias texb 'latexmk -pdf -interaction=nonstopmode -synctex=1'
alias texw 'latexmk -pdf -pvc -interaction=nonstopmode -synctex=1'
alias texc 'latexmk -c'

if status is-interactive
    # Warp Dark Palette
    set -g fish_color_normal E6EDF3
    set -g fish_color_command 7AA2F7 --bold
    set -g fish_color_param 9DA5B4
    set -g fish_color_keyword E6EDF3 --bold
    set -g fish_color_quote 4FD1A5
    set -g fish_color_redirection 56D4DD
    set -g fish_color_end 58A6FF
    set -g fish_color_error F47067
    set -g fish_color_comment 6B7280
    set -g fish_color_operator F6C177
    set -g fish_color_escape C678DD
    set -g fish_color_autosuggestion 4B5563
    set -g fish_color_search_match --background=2F3342
    set -g fish_color_selection --background=2F3342 --bold --italics

    # Starship prompt for fish
    if command -v starship >/dev/null 2>&1
        starship init fish | source
    end

end

# Disable fish welcome message
set -g fish_greeting
