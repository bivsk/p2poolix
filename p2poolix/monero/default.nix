{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.p2poolix.monero;
  p2poolix = config.p2poolix;
in
{
  options.p2poolix.monero = {
    settings = lib.mkOption {
      inherit (configFormat) type;
      default = { };
      description = ''
        Configuration included in monero base node `config.toml`.
      '';
    };

    environmentFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      example = "/var/lib/monero/monero.env";
      description = ''
        Path to an EnvironmentFile for the monero service as defined in {manpage}`systemd.exec(5)`.

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

  config = lib.mkIf p2poolix.monero.enable {
    services.monero = {
      enable = true;
    };
  };
}
