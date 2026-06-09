{
  description = "ChimeraX is an application for visualizing and analyzing molecule structures such as proteins, RNA, DNA, lipids as well as gene sequences, electron microscopy maps, X-ray maps, 3D light microscopy and 3D medical imaging scans. It is the successor of the UCSF Chimera program.";
  # Pinned to nixos-24.11 to match the Ubuntu 24.04 ChimeraX .deb (glibc 2.39,
  # Qt 6.7). Older pins (22.05/d529e69, glibc 2.34) are too old for that build.
  inputs = { nixpkgs.url = "github:NixOS/nixpkgs/50ab793786d9de88ee30ec4e4c24fb4236fc2674"; };
  outputs = { self, nixpkgs }:
    let
      # allowUnfree is required: ChimeraX pulls in nvidia-x11 and the CUDA
      # toolkit, both of which nixpkgs refuses to evaluate otherwise.
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
      };
      chimerax = pkgs.callPackage ./default.nix {};
    in {
      packages = {
        x86_64-linux = {
        default = chimerax;
      };
      };
      devShells = {
        x86_64-linux = {
        default = pkgs.mkShell {
          packages = [ chimerax ];
        };
      };
      };
    };
}
