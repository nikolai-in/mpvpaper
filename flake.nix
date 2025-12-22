{
  description = "mpvpaper - video wallpaper player using mpv for wlroots";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Build the package once and expose it under multiple names.
        pkg = pkgs.stdenv.mkDerivation {
          pname = "mpvpaper";
          version = "1.8";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            meson
            ninja
            pkg-config
            wayland-scanner
          ];

          buildInputs = with pkgs; [
            wayland
            wayland-protocols
            mpv
            libGL
            libglvnd
          ];

          meta = with pkgs.lib; {
            description = "Video wallpaper player using mpv for wlroots";
            homepage = "https://github.com/GhostNaN/mpvpaper";
            license = licenses.gpl3Only;
            platforms = platforms.linux;
            mainProgram = "mpvpaper";
          };
        };
      in
      {
        # Expose the primary package under both `mpvpaper` and `default`.
        packages = {
          mpvpaper = pkg;
          default = pkg;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.mpvpaper ];

          packages = with pkgs; [
            # Development tools
            gdb
            valgrind
            clang-tools # For clangd LSP

            # Build tools already included via inputsFrom
          ];

          shellHook = ''
            echo "mpvpaper development environment"
            echo "Build with: meson setup build && ninja -C build"
            echo "Install with: ninja -C build install"
          '';
        };
      }
    );
}
