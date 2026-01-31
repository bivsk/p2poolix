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

    monero = {
      enable = mkOption {
        type = types.bool;
        default = cfg.enable;
        example = true;
        description = ''
          Whether or not to enable the Monero node.
        '';
      };
    };

    tari = {
      enable = mkOption {
        type = types.bool;
        default = cfg.enable;
        example = true;
        description = ''
          Whether or not to enable the Tari node.
        '';
      };
    };

    p2pool = {
      enable = mkOption {
        type = types.bool;
        default = cfg.enable;
        example = true;
        description = ''
          Whether or not to enable the Tari node.
        '';
      };

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

    mining = {
      enable = mkOption {
        type = types.bool;
        default = config.p2poolix.enable;
        example = true;
        description = ''
          Whether or not to enable mining.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      p2pool
    ];
  };
}
