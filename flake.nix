 {
    inputs={
        nixpkgs.url = "github:nixos/nixpkgs";
        flake-parts.url = "github:hercules-ci/flake-parts";
    };

    outputs=inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } 
      {
            systems = [ "x86_64-linux" "aarch64-darwin" ];
            imports = [ ./module.nix ];
            perSystem = { config, self', inputs', pkgs, system, ... }: let
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
                dbus
                libsoup
                webkitgtk
              ];
              buildInputs = with pkgs; [
                pkg-config 
                librsvg
                curl
                wget
                openssl_3
                cargo-tauri 
                cargo 
                rustc
                glib
                gtk3
              ];
            source = ./.;
            in 
                {   packages.tauri-build = 
                      pkgs.rustPlatform.buildRustPackage {
                            pname = "tauri-app";
                            version = "0.0.1";

                            src = source;

                            cargoLock = {
                                lockFile = ./Cargo.lock;
                                allowBuiltinFetchGit = true;
                              };
                            doCheck = false;
                            buildInputs = packages;
                            nativeBuildInputs = buildInputs; 
                            buildPhase = ''
                              export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
                              cargo tauri build
                            '';
                      };

                };
      };
}
