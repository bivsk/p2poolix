{
  description = "Mine Monero and Tari with P2Pool";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    {
      nixpkgs,
      self,
      ...
    }@inputs:
    let
      supportedSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "aarch64-darwin" # 64-bit ARM macOS
      ];
      forEachSupportedSystem =
        f:
        inputs.nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import inputs.nixpkgs { inherit system; };
          }
        );
    in
    {
      nixosModules.default = import ./p2poolix self;

      packages = forEachSupportedSystem (
        { pkgs }:
        {
          tari = pkgs.callPackage ./pkgs/tari.nix { };
        }
      );

      devShells = forEachSupportedSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = [
              pkgs.nixfmt
            ];
          };
        }
      );

      formatter = forEachSupportedSystem ({ pkgs }: pkgs.nixfmt-tree);
    };
}
