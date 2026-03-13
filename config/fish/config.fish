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
    # Fish colors aligned with glass + shadcn palette
    set -g fish_color_normal fafafa
    set -g fish_color_command 60a5fa
    set -g fish_color_param fafafa
    set -g fish_color_keyword c084fc
    set -g fish_color_quote 34d399
    set -g fish_color_redirection 22d3ee
    set -g fish_color_end facc15
    set -g fish_color_error fb7185
    set -g fish_color_comment a1a1aa
    set -g fish_color_operator 22d3ee
    set -g fish_color_escape facc15
    set -g fish_color_autosuggestion a1a1aa
    set -g fish_color_search_match --background=18181b
    set -g fish_color_selection --background=60a5fa

    # Starship prompt for fish
    if command -v starship >/dev/null 2>&1
        starship init fish | source
    end

end

# Disable fish welcome message
set -g fish_greeting
