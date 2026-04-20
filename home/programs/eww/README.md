# Eww Layout

This directory is organized by responsibility:

- `eww.yuck`: shared state and widget includes.
- `widgets/`: one file per widget or window.
- `styles/`: shared tokens in `_variables.scss`, shared primitives in `_base.scss`, and one partial per widget.
- `scripts/`: runtime helpers grouped by widget name.

Naming rules:

- Use semantic names based on behavior, for example `power-menu` instead of generic names like `settings`.
- Keep shared styles in `styles/_variables.scss` and `styles/_base.scss`.
- Add widget-specific classes with a widget prefix, for example `.power-menu-*`.
- When adding a widget, create matching files in `widgets/`, `styles/`, and `scripts/` only if the widget needs them.
