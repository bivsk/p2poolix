{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    cli
    concatStringsSep
    mkIf
    mkOption
    optionalAttrs
    types
    ;

  cfg = config.p2poolix.p2pool;
  p2poolix = config.p2poolix;
  tariCfg = config.p2poolix.tari;
  xmrAddress = p2poolix.monero.address;

  # P2Pool does not use a config file.
  # Specify configuration via CLI args.
  p2pArgs =
    cli.toCommandLine
      (optionName: {
        option = "--${optionName}";
        sep = null;
        explicitBool = false;
      })
      (
        {
          host = p2poolix.monero.rpc.address;
          ${cfg.chain} = (cfg.chain != "main");
          wallet = xmrAddress;
          stratum = "${cfg.address}:${toString cfg.port}";
        }
        // optionalAttrs tariCfg.enable {
          "merge-mine" =
            "tari://${tariCfg.grpc.address}:${toString tariCfg.grpc.port} ${tariCfg.walletAddress}";
        }
      );
in
{
  options.p2poolix.p2pool = {
    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = "Open ports in firewall for p2pool.";
    };

    address = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = "Address for p2pool to listen on.";
    };

    port = mkOption {
      type = types.port;
      default = 3333;
      description = "Port for p2pool to listen on.";
    };

    chain = mkOption {
      type = types.enum [
        "main"
        "mini"
        "nano"
      ];
      default = "main";
      example = "mini";
      description = "Desired p2pool chain to mine on.";
    };
  };

  config = mkIf cfg.enable {
    users.users.p2pool = {
      isSystemUser = true;
      group = "p2pool";
      description = "p2pool daemon user";
      home = "/var/lib/p2pool";
      createHome = true;
    };

    users.groups.p2pool = { };

    systemd.services.p2pool = {
      description = "p2pool daemon";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "p2pool";
        Group = "p2pool";
        # EnvironmentFile = lib.mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        ExecStart = "${pkgs.p2pool}/bin/p2pool ${concatStringsSep " " p2pArgs}";
        Restart = "always";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [
        cfg.rpc.port
        cfg.zmq.port
      ];
    };
  };
}
