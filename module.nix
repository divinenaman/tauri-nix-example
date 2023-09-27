{ lib, ... }:
{
  perSystem = { config, self', pkgs, system, ... }: let
    libraries = with pkgs; [
          webkitgtk
          gtk3
          cairo
          gdk-pixbuf
          glib
          dbus
          openssl_3
          librsvg
        ];
    packages = with pkgs; [
          curl
          wget
          pkg-config
          dbus
          openssl_3
          glib
          gtk3
          libsoup
          webkitgtk
          librsvg
          cargo
          cargo-tauri
          rustc
        ];
  in
  {
    devShells.tauri-dev = pkgs.mkShell {
          nativeBuildInputs = packages;
          shellHook =
            ''
              export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
            '';
    };
  };
}
