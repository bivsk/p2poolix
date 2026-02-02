{
  config,
  lib,
  ...
}:
let
  inherit (lib)
    mkAliasOptionModule
    mkIf
    mkOption
    types
    ;

  cfg = config.p2poolix.xmrig;
  p2poolCfg = config.p2poolix.p2pool;
in
{
  imports = [
    (mkAliasOptionModule [ "p2poolix" "xmrig" "package" ] [ "services" "xmrig" "package" ])
    (mkAliasOptionModule [ "p2poolix" "xmrig" "settings" ] [ "services" "xmrig" "settings" ])
  ];

  options = {
    p2poolix.xmrig = {
      "1gb-hugepages" = mkOption {
        type = types.bool;
        default = false;
        description = "Enable 1GB hugepages";
      };
      cacheQos = mkOption {
        type = types.bool;
        default = false;
        description = ''
          When enabled, all CPU cores which are not mining
          will not have access to the L3 cache.
          See: https://xmrig.com/docs/miner/randomx-optimization-guide/qos
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    services.xmrig = {
      enable = true;
      settings = {
        autosave = false;
        pools = [
          {
            url = "${p2poolCfg.address}:${toString p2poolCfg.port}";
          }
        ];
        randomx = {
          cacheQos = cfg.cacheQos;
          "1gb-pages" = cfg."1gb-hugepages";
        };
      };
    };
  };

  # TODO: make sure 4 pages is enough
  boot = mkIf cfg."1gb-hugepages" {
    kernelParams = [
      "hugepagesz=1G"
      "hugepages=4"
      "default_hugepagesz=2M"
    ];
  };
}
