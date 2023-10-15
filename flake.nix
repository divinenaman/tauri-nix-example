 {
    inputs={
        nixpkgs.url = "github:nixos/nixpkgs";
        flake-parts.url = "github:hercules-ci/flake-parts";
        crane.url = "github:ipetkov/crane";
    };

    outputs=inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } 
      {
            systems = [ "x86_64-linux" "aarch64-darwin" ];
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
              craneLib = inputs.crane.mkLib pkgs;
              cleanedSource = pkgs.lib.cleanSourceWith {
                src = craneLib.path source;
                filter = path: _type: 
                (builtins.match ".*tauri.*" path != null) ||
                (builtins.match ".*icons.*" path != null) ||
                (craneLib.filterCargoSources path _type);
              };
              craneDepsActifact = craneLib.buildDepsOnly {
                src = cleanedSource;
                buildInputs = packages;
                nativeBuildInputs = buildInputs;
              };
              cranePackageArtifact = craneLib.buildPackage {
                src = cleanedSource;
                cargoArtifacts = craneDepsActifact;
                buildInputs = packages;
                nativeBuildInputs = buildInputs;
                buildPhase = ''
                  export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
                  chmod -R 777 target
                  ls -lLRa
                  cargo tauri build
                '';
                unpackPhase = ''
                    unpackPhase
                    ls -la
                  '';
                patchPhase = ''
                      patchPhase
                      ls -la
                    '';
                configurePhase = ''
                        configurePhase
                        ls -la
                      '';
              };
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

                      packages.crane-tauri-build = cranePackageArtifact;

                      devShells.tauri-dev = pkgs.mkShell {
                        nativeBuildInputs = packages ++ buildInputs;
                        shellHook = ''
                          export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath libraries}:$LD_LIBRARY_PATH
                        '';
                      };


                };
        };
}
