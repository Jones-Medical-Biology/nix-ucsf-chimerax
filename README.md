# nix-ucsf-chimerax

A Nix flake to build and run [UCSF ChimeraX](https://github.com/RBVI/ChimeraX).

## Providing the source

ChimeraX is a registration-gated ~418 MB `.deb`. It is **not** committed to
this repo — it's too big for GitHub (100 MB hard limit) and shouldn't be
redistributed anyway. Instead it's referenced by hash via `requireFile`, so you
add it to your local Nix store once:

1. Download the **Ubuntu 22.04** build from
   <https://www.cgl.ucsf.edu/chimerax/download.html> and rename it to
   `chimerax-rc.deb`.
2. Compute its hash and paste it into the `sha256` field in `default.nix`:
   ```sh
   nix-prefetch-url file://$PWD/chimerax-rc.deb
   ```
3. Add it to the Nix store:
   ```sh
   nix-store --add-fixed sha256 chimerax-rc.deb
   ```

If the file isn't in the store yet, the build aborts early and prints these
exact steps.

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
