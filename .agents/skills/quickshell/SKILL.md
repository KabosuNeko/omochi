---
name: quickshell
description: Build, lint, and troubleshoot Quickshell QML configurations or source builds. Use for shell.qml, Quickshell modules, qmllint setup, runtime validation, packaging, version-matched API guidance, and adapting Quickshell shells across compositors (Hyprland, niri, Sway). Triggers: quickshell, qs, qmllint, qmlls, shell.qml, PanelWindow, IpcHandler, WlrLayershell, Quickshell.Services, adapting Hyprland shell to niri/Sway, rewriting Hyprland-specific QML imports.
compatibility: opencode
---

# Quickshell

Build, lint, and run Quickshell-based desktop shells. Load this skill whenever
editing QML files that `import Quickshell.*`, debugging `qs.*` imports,
packaging a shell config, or adapting a shell across compositors.

## Core Workflow

1. Locate the project shape:
   - Config project: has `shell.qml` and QML files.
   - Source checkout: has Quickshell CMake files and usually `BUILD.md`.
   - Packaged config: has a named config intended for
     `$XDG_CONFIG_HOME/quickshell/<name>` or `$XDG_CONFIG_DIRS/quickshell/<name>`.
2. Read local project instructions first (`AGENTS.md`, `README`, docs,
   package metadata).
3. For QML edits, resolve this skill's absolute directory, keep the working
   directory at the target project, and run its `scripts/quickshell-qmllint`
   helper before treating `qmllint` import errors as real.
4. For runtime validation, load the managed config with `qs --path <dir>` or
   `qs --config <name>` in a real or nested compositor session.
5. For documentation or API work, detect the project's target version from its
   package metadata, lock files, source checkout, or `qs --version`. Use the
   matching official versioned docs. If the project has no version signal, use
   the latest stable release and state the version selected.
6. For source builds, use CMake/Ninja and disable optional features whose
   dependencies are absent.

## Resources

- Read `references/linting.md` when linting QML, configuring `qmllint`/`qmlls`,
  or diagnosing missing `Quickshell` or `qs.*` type declarations.
- Read `references/build-and-run.md` when installing Quickshell, running a
  config, packaging a config, or building Quickshell from source.
- Read `references/docs-map.md` when selecting version-matched official docs
  pages or type references.

## Fast Commands

From the target project root, set the resolved absolute skill directory and
lint all QML under the nearest `shell.qml` root:

```sh
quickshell_skill_dir="$HOME/.config/opencode/skills/quickshell"
"$quickshell_skill_dir/scripts/quickshell-qmllint"
```

Lint a specific config root:

```sh
"$quickshell_skill_dir/scripts/quickshell-qmllint" --root "$PWD/qml"
```

Run a config for validation:

```sh
qs --path ./qml --no-duplicate
```

Build Quickshell source:

```sh
cmake -GNinja -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build
cmake --install build
```

## Compositor Adaptation

When adapting a shell across compositors:

- `Quickshell.Hyprland` (Hyprland only) provides `Hyprland.workspaces`,
  `Hyprland.focusedWorkspace`, `Hyprland.dispatch(...)`, and
  `ToplevelManager.activeToplevel`. None of these exist for niri/Sway.
- For niri: replace with `Process` calls to `niri msg --json workspaces`,
  `niri msg --json windows`, and `niri msg action focus-workspace <id>`.
  Poll via `Timer` + `Process` for workspace state; parse JSON via
  `StdioCollector` + `JSON.parse`.
- For Sway: use `swaymsg -t get_workspaces`, `swaymsg -t get_tree`,
  `swaymsg focus workspace <n>`.
- `WlrLayershell.layer`, `keyboardFocus`, `exclusiveZone`, and `margins` are
  compositor-agnostic (layer-shell protocol). Keep them.
- `Quickshell.Wayland`, `Quickshell.Services.UPower`,
  `Quickshell.Services.Notifications`, `Quickshell.Services.Mpris`,
  `Quickshell.Services.Pipewire`, and `Quickshell.Io` are compositor-agnostic.
- `PanelWindow` with `WlrLayershell.Top` + `exclusiveZone` works on niri and
  Sway without changes.

## Guardrails

- Prefer official docs matching the project's Quickshell version. Do not apply
  current APIs to an older pinned configuration without checking compatibility.
- Do not replace runtime `qs.*` imports with relative imports only to satisfy
  stock `qmllint`; create lint-only module maps instead.
- Treat plain `qmllint` failures about `Quickshell` or `qs.*` imports as setup
  failures until explicit import roots have been supplied.
- Validate UI/runtime behavior in an actual compositor/Wayland session when
  windows, panels, focus, IPC, or services are involved.
- When adapting compositor-specific imports (Hyprland → niri/Sway), always
  remove the `import Quickshell.Hyprland` line and replace every usage site
  with the target compositor's IPC. Do not leave dead imports.
