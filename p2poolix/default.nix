flakeSelf:
{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.p2poolix;
in
{
  imports = [
    (import ./tari flakeSelf)
  ];

  options.p2poolix = {
    enable = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Whether or not to enable the p2poolix module. By default, this runs:

        - **Monero node**: Setup and run a full Monero node.
        - **P2Pool**: Decentralized mining pool.
        - **Merge mining**: Optionally, mine Tari alongside Monero.
        - **Tari node**: Minotari base node used for merge mining.
      '';
    };

    mining = {
      enable = mkEnableOption "Enable mining via p2pool";

      p2pool = {
        enable = mkEnableOption "Enable p2pool";

        chain = mkOption {
          type = types.enum [
            "main"
            "mini"
            "nano"
          ];
          default = "main";
          example = "mini";
          description = ''
            Desired p2pool chain to mine on.
          '';
        };
      };

      mergeMining = {
        enable = mkEnableOption "Enable merge mining";

        chain = mkOption {
          type = types.enum [ "tari" ];
          default = "tari";
          example = "tari";
          description = ''
            Desired chain to merge mine.
          '';
        };

        address = mkOption {
          type = types.nullOr types.str;
          default = null;
          example = "t1...";
          description = ''
            Payment address for merge mined rewards.
          '';
        };
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      p2pool
    ];
  };
}
