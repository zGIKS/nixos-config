set -gx EDITOR fresh
set -gx VISUAL fresh
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
    # Monochrome Glass Palette (White & Dark)
    set -g fish_color_normal ffffff
    set -g fish_color_command ffffff --bold
    set -g fish_color_param d1d1d1
    set -g fish_color_keyword ffffff --bold
    set -g fish_color_quote a1a1aa
    set -g fish_color_redirection ffffff
    set -g fish_color_end ffffff
    set -g fish_color_error fca5a5
    set -g fish_color_comment 71717a
    set -g fish_color_operator ffffff
    set -g fish_color_escape ffffff
    set -g fish_color_autosuggestion 52525b
    set -g fish_color_search_match --background=3f3f46
    set -g fish_color_selection --background=ffffff --bold --italics

    # Starship prompt for fish
    if command -v starship >/dev/null 2>&1
        starship init fish | source
    end

end

# Disable fish welcome message
set -g fish_greeting
