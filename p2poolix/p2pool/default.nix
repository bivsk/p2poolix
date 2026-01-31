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

  cfg = config.p2poolix.p2pool;
  p2poolix = config.p2poolix;
  xmrAddress = p2poolix.monero.address;
in
{
  options.p2poolix.p2pool = {
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
        ExecStart = "${pkgs.p2pool}/bin/p2pool --mini --wallet ${xmrAddress}";
        Restart = "always";
      };
    };
  };
}
