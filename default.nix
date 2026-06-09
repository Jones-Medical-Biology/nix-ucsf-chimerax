{ pkgs, stdenv, dpkg, glibc, gcc-unwrapped, autoPatchelfHook }:
let

  # Please keep the version x.y.0.z and do not update to x.y.76.z because the
  # source of the latter disappears much faster.
  version = "rc";

  # ChimeraX is distributed as a registration-gated .deb, so it cannot be
  # fetched reproducibly with a stable hash. Download the Ubuntu 22.04 build
  # from https://www.cgl.ucsf.edu/chimerax/download.html, rename it to
  # "chimerax-rc.deb", drop it next to this file, and `git add` it (flakes only
  # see git-tracked files). Then `nix build` will pick it up.
  src =
    if builtins.pathExists ./chimerax-rc.deb then ./chimerax-rc.deb
    else throw ''
      chimerax-rc.deb not found next to default.nix.
      Download the Ubuntu 22.04 ChimeraX .deb from
      https://www.cgl.ucsf.edu/chimerax/download.html, rename it to
      chimerax-rc.deb, place it in this directory, and `git add` it.
    '';
  libnsl = stdenv.mkDerivation rec {
    pname = "libnsl";
    version = "1.3.0";
    src = pkgs.fetchFromGitHub {
      owner = "thkukuk";
      repo = pname;
      rev = "v${version}";
      sha256 = "1dayj5i4bh65gn7zkciacnwv2a0ghm6nn58d78rsi4zby4lyj5w5";
    };

    nativeBuildInputs = [ pkgs.autoreconfHook pkgs.pkg-config ];
    buildInputs = [ pkgs.libtirpc ];
  };
  my-python-packages = python-packages: with python-packages; [
    webencodings
    xkbcommon
   # pyqt6
  ];
  python-with-my-packages = pkgs.python39.withPackages my-python-packages;
in
stdenv.mkDerivation rec {
  name = "chimerax-${version}";

  system = "x86_64-linux";

  inherit src;

  # Required for compilation
  nativeBuildInputs = [
    autoPatchelfHook # Automatically setup the loader, and do the magic
    #pkgs.addOpenGLRunpath
    #pkgs.cudaPackages.autoAddOpenGLRunpathHook
    pkgs.qt6.wrapQtAppsHook
    pkgs.makeWrapper
    dpkg
  ];

  # Required at running time
  buildInputs = [
    glibc
    #gcc-unwrapped
    pkgs.linuxKernel.packages.linux_5_19.nvidia_x11
    pkgs.libffi
    pkgs.qt6.wrapQtAppsHook
    pkgs.glib
    pkgs.gdk-pixbuf
    pkgs.cairo
    pkgs.pango
    pkgs.udev
    pkgs.libGLU
    pkgs.alsa-lib
    pkgs.gtk3
    pkgs.webkitgtk
    pkgs.pkg-config
    # X11 / xcb libraries needed by Qt's bundled "xcb" platform plugin. These
    # were previously commented out, which is what broke the GUI ("keymaps?").
    pkgs.xorg.libX11
    pkgs.xorg.libxcb
    pkgs.xorg.libXcursor
    pkgs.xorg.libXrandr
    pkgs.xorg.libXi
    pkgs.xorg.libXext
    pkgs.xorg.libXrender
    pkgs.xorg.libXtst
    pkgs.xorg.libXcomposite
    pkgs.xorg.libXdamage
    pkgs.xorg.libXfixes
    pkgs.xorg.xcbutil
    pkgs.xorg.xcbutilwm
    pkgs.xorg.xcbutilimage
    pkgs.xorg.xcbutilkeysyms
    pkgs.xorg.xcbutilrenderutil
    pkgs.xorg.xcbutilcursor
    pkgs.fontconfig
    pkgs.freetype
    pkgs.dbus
    pkgs.libGL
    pkgs.xorg.xkbevd
    pkgs.kbd
    pkgs.xkeyboard_config
    pkgs.libxkbcommon
    pkgs.gcc-unwrapped
    pkgs.ffmpeg
    pkgs.qt6.qt3d
    pkgs.qt6.qtquick3d
    pkgs.qt6.qtwebview
    pkgs.opencl-info
    pkgs.ncurses
    pkgs.libtirpc
    libnsl
    pkgs.opencl-clang
    pkgs.opencl-headers
    pkgs.rocm-opencl-runtime
    pkgs.opencl-clhpp
    pkgs.conda
    pkgs.vial
    pkgs.mysql80
    pkgs.cudaPackages.cudatoolkit
    pkgs.openssl_3
    python-with-my-packages
  ];
  propagatedBuildInputs = buildInputs;
  unpackPhase = "true";
  dontAutoPatchelf = true;
  dontStrip = true;

  # Qt's xcb plugin reads the XKB keyboard rules at runtime; without this it
  # fails with "Could not create XKB context" and the GUI never comes up.
  # FONTCONFIG_FILE points the bundled Qt at a usable fontconfig configuration.
  qtWrapperArgs = [
    "--set QT_XKB_CONFIG_ROOT ${pkgs.xkeyboard_config}/share/X11/xkb"
    "--set FONTCONFIG_FILE ${pkgs.fontconfig.out}/etc/fonts/fonts.conf"
  ];

  # Extract and copy executable in $out/bin
  installPhase = ''
    mkdir -p $out
    dpkg -x $src $out
    cp -av $out/usr/lib/ucsf-chimerax/* $out
    rm -rf $out/usr
    #rm -rf $out/lib/python3.9
    rm -rf $out/bin/amber20
    rm $out/bin/python3.9
    rm $out/lib/libpython*
  '';

  postFixup = ''
    autoPatchelf $out/bin
    autoPatchelf $out/lib
    dpkg -x $src $out
    #mkdir $out/lib/python3.9
    #cp -av $out/usr/lib/ucsf-chimerax/lib/python3.9/site-packages $out/lib/site-packages
    rm -rf $out/usr
  '';

  # meta = with stdenv.lib; {
  #   description = "ChimeraX";
  #   homepage = https://www.cgl.ucsf.edu/chimerax/;
  #   license = licenses.mit;
  #   maintainers = with stdenv.lib.maintainers; [ ];
  #   platforms = [ "x86_64-linux" ];
  # };
}
