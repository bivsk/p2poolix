{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.p2poolix.xmrig;
  p2poolix = config.p2poolix;
in
{
  imports = [
    (mkAliasOptionModule [ "p2poolix" "xmrig" "settings" ] [ "services" "xmrig" "settings" ])
    (mkAliasOptionModule [ "p2poolix" "xmrig" "package" ] [ "services" "xmrig" "package" ])
  ];

  # options.p2poolix.xmrig = {
  #   settings = mkOption {
  #     type = json.type;
  #     default = { };
  #     description = ''
  #       XMRig configuration. Refer to
  #       <https://xmrig.com/docs/miner/config>
  #       for details on supported values.
  #     '';
  #   };
  # };

  config = mkIf cfg.enable {
    services.xmrig = {
      enable = true;
      settings = {
        pools = [
          {
            url = "127.0.0.1:3333";
          }
        ];
      };
    };
  };
}
