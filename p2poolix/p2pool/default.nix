{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.p2poolix.p2pool;
  p2poolix = config.p2poolix;
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

  config = lib.mkIf p2poolix.p2pool.enable {
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
        ExecStart = "${pkgs.p2pool}/bin/p2pool --mini --wallet 55LTR8KniP4LQGJSPtbYDacR7dz8RBFnsfAKMaMuwUNYX6aQbBcovzDPyrQF9KXF9tVU6Xk3K8no1BywnJX6GvZX8yJsXvt";
        Restart = "always";
      };
    };
  };
}
