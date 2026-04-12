---
name: catppuccin-tmux
description: Use when editing ~/.tmux.conf catppuccin theme settings — status line modules, window styles, flavor, colors, custom modules. Covers load order rules, available modules/options, theme color vars, and common gotchas so the agent doesn't need to re-fetch the upstream docs.
---

# Catppuccin tmux

Reference for tweaking the [catppuccin/tmux](https://github.com/catppuccin/tmux) theme. Source of truth is `docs/` in that repo — fetch it again if something here looks stale or the user asks about a feature not listed.

## Load order (critical)

In `~/.tmux.conf`:

1. All `@catppuccin_*` options must be set **before** `run .../catppuccin.tmux`.
2. Options that do **not** start with `@` (like `status-left`, `status-right`) must be set **after** the plugin runs, because they reference expanded `#{@thm_*}` / `#{@catppuccin_status_*}` variables the plugin defines at load.
3. If using TPM: load catppuccin first, set status options, then `run '~/.tmux/plugins/tpm/tpm'`.
4. Changes don't always hot-reload — tell the user to `killall tmux` and start fresh when something seems stuck.
5. Never use `-o` with `@catppuccin_*` (it's set-if-unset, silently ignores the second load).

## Flavor

```tmux
set -g @catppuccin_flavor "mocha"  # latte | frappe | macchiato | mocha
```

## Theme color variables

After the plugin loads, the full palette is exposed as tmux user options. Reference them with `#{@thm_<name>}` inside format strings, and use the `-F` flag on `set` when the value contains format expansions:

```
@thm_bg  @thm_fg  @thm_crust  @thm_mantle
@thm_surface_0 / _1 / _2    @thm_overlay_0 / _1 / _2    @thm_subtext_0 / _1
@thm_rosewater  @thm_flamingo  @thm_pink  @thm_mauve  @thm_red  @thm_maroon
@thm_peach  @thm_yellow  @thm_green  @thm_teal  @thm_sky  @thm_sapphire
@thm_blue  @thm_lavender
```

## Status line background

```tmux
set -g @catppuccin_status_background "default"   # theme default
# or "none" for transparent, or a hex like "#1e1e2e"
```

## Built-in status modules

Set each with `@catppuccin_status_<module>`, then add to `status-left` / `status-right` using the `E:` prefix (for expansion) and `-agF` when appending format strings:

```tmux
set -g status-right-length 100
set -g status-left ""
set -g status-right "#{E:@catppuccin_status_application}"
set -agF status-right "#{E:@catppuccin_status_session}"
set -agF status-right "#{E:@catppuccin_status_directory}"
set -agF status-right "#{E:@catppuccin_status_date_time}"
```

Available modules:

| Module         | Notes                                              |
| -------------- | -------------------------------------------------- |
| `application`  | Current pane command                               |
| `directory`    | Current pane path                                  |
| `session`      | tmux session name                                  |
| `user`         | `$USER`                                            |
| `host`         | hostname                                           |
| `date_time`    | Configurable via `@catppuccin_date_time_text`      |
| `load`         | System load (built-in, no deps)                    |
| `battery`      | Requires [tmux-battery](https://github.com/tmux-plugins/tmux-battery) |
| `cpu`          | Requires [tmux-cpu](https://github.com/tmux-plugins/tmux-cpu) |
| `ram`          | Requires tmux-cpu                                  |
| `weather`      | Requires tmux-weather or tmux-clima                |
| `gitmux`       | Requires [gitmux](https://github.com/arl/gitmux)   |
| `pomodoro_plus`| Requires tmux-pomodoro-plus                        |
| `kubernetes`   | Requires tmux-kubectx                              |

Per-module overrides (all optional):

```tmux
set -g  @catppuccin_<module>_icon  " "
set -gF @catppuccin_<module>_color "#{@thm_mauve}"
set -g  @catppuccin_<module>_text  "#{pane_current_command}"
set -gF @catppuccin_status_<module>_bg_color "#{@thm_surface_0}"
```

Set any of these to `""` to remove that piece. Setting the whole `@catppuccin_status_<module>` to `""` removes the module.

## Window styles

```tmux
set -g @catppuccin_window_status_style "rounded"
# basic | rounded | slanted | custom | none
```

Common window text overrides (use these when the pane title isn't what the user wants shown — e.g. if their shell isn't setting the title):

```tmux
set -g @catppuccin_window_text         "#W"                      # inactive
set -g @catppuccin_window_current_text "#W"                      # active
# or "#{b:pane_current_path}" for basename of cwd
```

Other window options worth knowing: `@catppuccin_window_number_position` (left/right), `@catppuccin_window_flags` (icon/text/none), `@catppuccin_window_current_fill`, `@catppuccin_window_default_fill`, and the flag icons (`@catppuccin_window_flags_icon_activity` etc.).

## Custom modules

Two approaches:

**1. Freeform** — just append to the status with inline `#[...]` styling:

```tmux
set -agF status-right "#[fg=#{@thm_crust},bg=#{@thm_teal}] ##H "
```

Note the `##H` (double `#`) to escape — tmux expands `#H` itself otherwise.

**2. Catppuccin-formatted** — reuse the plugin's module renderer so a custom module matches the built-in look. This must be set **before** the plugin runs:

```tmux
%hidden MODULE_NAME="my_module"
set -g  "@catppuccin_${MODULE_NAME}_icon" " "
set -gF "@catppuccin_${MODULE_NAME}_color" "#{@thm_pink}"
set -g  "@catppuccin_${MODULE_NAME}_text"  "#{pane_current_command}"
source "/path/to/catppuccin/tmux/utils/status_module.conf"
```

Then reference it like a built-in: `#{E:@catppuccin_status_my_module}`.

## Reset

```tmux
set -g @catppuccin_reset "true"
```

Wipes all theme options back to plugin defaults. To reset **and** re-apply customizations, the plugin must be run twice — once with reset, then again after re-setting options.

## Troubleshooting checklist

When a change isn't taking effect, walk through these in order:

1. `killall tmux` and restart (not just detach/attach).
2. Confirm all `@catppuccin_*` options sit **above** the `run .../catppuccin.tmux` line.
3. Confirm `status-left`/`status-right` sit **below** that line.
4. Check for typos — "catppuccin" has two c's and two p's.
5. Confirm a Nerd Font is installed and active in the terminal if icons show as boxes.
6. Remove any `-o` flags from `@catppuccin_*` lines.
7. Make sure `-F` is used when the value contains `#{...}` expansions.

## Upstream docs

- `docs/reference/configuration.md` — every option and its default
- `docs/reference/status-line.md` — module system details
- `docs/tutorials/02-custom-status.md` — custom module patterns
- `docs/guides/troubleshooting.md` — official FAQ
- `docs/explanation/design.md` — "do colors, do colors well" philosophy; explains why some features won't be added
