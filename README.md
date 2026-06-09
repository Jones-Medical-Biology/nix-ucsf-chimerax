# nix-ucsf-chimerax

A Nix flake to build and run [UCSF ChimeraX](https://github.com/RBVI/ChimeraX).

## Providing the source

ChimeraX is distributed as a registration-gated `.deb`, so it cannot be
fetched reproducibly with a stable hash. Before building:

1. Download the **Ubuntu 22.04** build from
   <https://www.cgl.ucsf.edu/chimerax/download.html>.
2. Rename it to `chimerax-rc.deb` and place it next to `default.nix`.
3. `git add chimerax-rc.deb` — flakes only see git-tracked files.

If the file is missing the build aborts early with a message explaining this.

## Building / running

```sh
nix build         # produces ./result
./result/bin/ChimeraX
```

Unfree packages (nvidia-x11, the CUDA toolkit) are pulled in, so the flake
sets `config.allowUnfree = true` for you.

## Status

- Builds via `dpkg -x` + `autoPatchelfHook`; the flake evaluates and the
  derivation instantiates cleanly.
- The GUI requires Qt's `xcb` platform plugin. The X11/xcb libraries it needs
  are now in `buildInputs`, and `QT_XKB_CONFIG_ROOT` is set at wrap time to fix
  the "could not create XKB context" / keymap failure. Verify on a machine with
  a display + GPU.
