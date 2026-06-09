# nix-ucsf-chimerax

A Nix flake to build and run [UCSF ChimeraX](https://github.com/RBVI/ChimeraX).

## Providing the source

ChimeraX is a registration-gated ~418 MB `.deb`. It is **not** committed to
this repo — it's too big for GitHub (100 MB hard limit) and shouldn't be
redistributed anyway. Instead it's referenced by hash via `requireFile`, so you
add it to your local Nix store once:

1. Download the **Ubuntu 24.04** build
   (`ucsf-chimerax_1.11.1ubuntu24.04_amd64.deb`) from
   <https://www.cgl.ucsf.edu/chimerax/download.html>.
2. Add it to the Nix store:
   ```sh
   nix-store --add-fixed sha256 ucsf-chimerax_1.11.1ubuntu24.04_amd64.deb
   ```

The hash is already pinned in `default.nix`. If the file isn't in the store
yet, the build aborts early and prints these exact steps. (If you have a
different build, update `debName` and `sha256` in `default.nix`.)

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
