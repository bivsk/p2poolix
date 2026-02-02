flakeSelf:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkDefault
    mkIf
    mkOption
    types
    ;

  tariPkg = flakeSelf.packages.${pkgs.system}.tari;

  cfg = config.p2poolix.tari;
  p2poolix = config.p2poolix;
  configFormat = pkgs.formats.toml { };
  configFile = configFormat.generate "config.toml" cfg.settings;
in
{
  options.p2poolix.tari = {
    grpc = {
      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "gRPC address for Tari base node.";
      };
      port = mkOption {
        type = types.port;
        default = 18142;
        description = "gRPC port for Tari base node.";
      };
    };

    walletGrpc = {
      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "gRPC address for Tari wallet.";
      };
      port = mkOption {
        type = types.port;
        default = 18143;
        description = "gRPC port for Tari wallet.";
      };
    };

    walletAddress = mkOption {
      type = types.str;
      default = "1259VHQPS6MovoWhqJuxZASf7BMtiVgqvM8RKBRm3zisLGmZEnKnmDRVyGZQt66bRdgtjoSiZUALk174iHu41aCyEGw";
      description = "Tari address for mining rewards.";
    };

    settings = mkOption {
      inherit (configFormat) type;
      default = { };
      description = ''
        Configuration included in Tari base node `config.toml`.
      '';
    };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open port in firewall for Tari gRPC.";
    };

    environmentFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      example = "/var/lib/tari/tari.env";
      description = ''
        Path to an EnvironmentFile for the tari service as defined in {manpage}`systemd.exec(5)`.

        Secrets may be passed to the service by specifying placeholder variables in the Nix config
        and setting values in the environment file.

        Example:

        ```
        # In environment file:
        MINING_ADDRESS=888tNkZrPN6JsEgekjMnABU4TBzc2Dt29EPAvkRxbANsAnjyPbb3iQ1YBRk1UXcdRsiKc9dhwMVgN5S9cQUiyoogDavup3H
        ```

        ```
        # Service config
        services.monero.mining.address = "$MINING_ADDRESS";
        ```
      '';
    };
  };

  config = mkIf p2poolix.tari.enable {
    p2poolix.tari.settings = {
      common.base_path = "/var/lib/tari";
      base_node = {
        grpc_enabled = mkDefault true;
        grpc_address = "/ip4/${cfg.grpc.address}/tcp/${toString cfg.grpc.port}";
      };
      wallet = {
        grpc_address = "/ip4/${cfg.walletGrpc.address}/tcp/${toString cfg.walletGrpc.port}";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.grpc.port
        cfg.walletGrpc.port
      ];
    };

    users.users.tari = {
      isSystemUser = true;
      group = "tari";
      description = "Tari daemon user";
      home = "/var/lib/tari";
      createHome = true;
    };

    users.groups.tari = { };

    systemd.services.minotari-node = {
      description = "minotari base node";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "tari";
        Group = "tari";
        ExecStart = "${tariPkg}/bin/minotari_node --base-path ${cfg.settings.common.base_path} --config ${configFile} --non-interactive-mode --network mainnet --disable-splash-screen";
        EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        Environment = [
          "MINOTARI_NODE_ENABLE_MINING=${toString p2poolix.xmrig.enable}"
        ];
        Restart = "always";
      };
    };
  };
}
