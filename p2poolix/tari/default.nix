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

  cfg = config.p2poolix.tari;
  p2poolix = config.p2poolix;

  tariPkg = flakeSelf.packages.${pkgs.system}.tari;

  configFormat = pkgs.formats.toml { };
  configFile = configFormat.generate "config.toml" cfg.settings;
in
{
  options.p2poolix.tari = {
    settings = mkOption {
      inherit (configFormat) type;
      default = { };
      description = ''
        Configuration included in Tari base node `config.toml`.
      '';
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
      base_node.grpc_address = mkDefault "/ip4/127.0.0.1/tcp/18142";
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
        EnvironmentFile = mkIf (cfg.environmentFile != null) [ cfg.environmentFile ];
        ExecStart = "${tariPkg}/bin/minotari_node --base-path ${cfg.settings.common.base_path} --config ${configFile} --non-interactive-mode --network mainnet --disable-splash-screen";
        Restart = "always";
      };
    };
  };
}
