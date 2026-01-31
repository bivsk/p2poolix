flakeSelf:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    types
    ;

  cfg = config.p2poolix;
in
{
  imports = [
    (import ./tari flakeSelf)
    ./monero
    ./xmrig
    ./p2pool
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

      # TODO: use alias? p2poolix.monero.address -> services.monero.address
      # need to be able to easily reference from submodules
      address = mkOption {
        type = types.str;
        default = "888tNkZrPN6JsEgekjMnABU4TBzc2Dt29EPAvkRxbANsAnjyPbb3iQ1YBRk1UXcdRsiKc9dhwMVgN5S9cQUiyoogDavup3H"; # donation address
        example = "888tNkZrPN6JsEgekjMnABU4TBzc2Dt29EPAvkRxbANsAnjyPbb3iQ1YBRk1UXcdRsiKc9dhwMVgN5S9cQUiyoogDavup3H";
        description = ''
          Monero address where to send mining rewards.
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

    };

    xmrig = {
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
