{
  description = "Mine Monero and Tari with P2Pool";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    hercules-ci-effects.url = "github:hercules-ci/hercules-ci-effects";
    hercules-ci-effects.inputs.nixpkgs.follows = "nixpkgs";
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
    }
    // {
      herculesCI = inputs.hercules-ci-effects.lib.mkHerculesCI { inherit inputs; } {
        hercules-ci.flake-update = {
          enable = true;
          baseMerge.enable = true;
          flakes.".".commitSummary = "chore: update flake.lock";
          pullRequestTitle = "chore: update flake.lock";
          autoMergeMethod = "squash";

          when = {
            hour = [ 0 ];
            dayOfWeek = [ "Sun" ];
          };
        };
        herculesCI.ciSystems = [ "x86_64-linux" ];
      };
    };
}
