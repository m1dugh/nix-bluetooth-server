{
    description = "A flake for nix-bluetooth-server project.";

    inputs = {
        nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
        nixos-hardware.url = "github:nixos/nixos-hardware";
    };

    outputs = {
        nixpkgs,
        nixos-hardware,
        ...
    }: 
    let inherit (nixpkgs) lib;
    in rec {
        nixosModules = rec {
            bluetooth-server = {
                imports = [
                    ./server
                ];
            };

            test-module = {
                imports = [
                    bluetooth-server
                    ({
                        users.users.root = {
                            password = "toor";
                        };
                        system.stateVersion = "23.11";

                        networking.hostName = "test";
                        midugh.bluetooth-server.enable = true;
                    })
                ];
            };
        };

        nixosConfigurations.test-rpi = lib.nixosSystem {
            modules = [
                nixosModules.test-module
                nixos-hardware.nixosModules.raspberry-pi-4
                "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
                ({
                 nixpkgs = {
                     hostPlatform = "aarch64-linux";
                     config.allowUnsupportedSystems = true;
                     overlays = [(final: prev: {
                             makeModulesClosure = x:
                             prev.makeModulesClosure (x // {
                                     allowMissing = true;
                                     });
                             })];
                 };
                })
            ];
        };
    };
}
