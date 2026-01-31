{
  config,
  lib,
  ...
}:
with lib;
let
  cfg = config.p2poolix.monero;
  p2poolix = config.p2poolix;
in
{
  # re-use options from nixos monero module
  imports = [
    (mkAliasOptionModule [ "p2poolix" "monero" "dataDir" ] [ "services" "monero" "dataDir" ])
    (mkAliasOptionModule [ "p2poolix" "monero" "banlist" ] [ "services" "monero" "banlist" ])
    (mkAliasOptionModule [ "p2poolix" "monero" "extraConfig" ] [ "services" "monero" "extraConfig" ])
    (mkAliasOptionModule
      [ "p2poolix" "monero" "environmentFile" ]
      [ "services" "monero" "environmentFile" ]
    )
    (mkAliasOptionModule [ "p2poolix" "monero" "prune" ] [ "services" "monero" "prune" ])
    (mkAliasOptionModule
      [ "p2poolix" "monero" "priorityNodes" ]
      [ "services" "monero" "priorityNodes" ]
    )
    (mkAliasOptionModule [ "p2poolix" "monero" "extraNodes" ] [ "services" "monero" "extraNodes" ])
    (mkAliasOptionModule
      [ "p2poolix" "monero" "exclusiveNodes" ]
      [ "services" "monero" "exclusiveNodes" ]
    )
    (mkAliasOptionModule [ "p2poolix" "monero" "rpc" "user" ] [ "services" "monero" "rpc" "user" ])
    (mkAliasOptionModule
      [ "p2poolix" "monero" "rpc" "password" ]
      [ "services" "monero" "rpc" "password" ]
    )
    (mkAliasOptionModule [ "p2poolix" "monero" "rpc" "port" ] [ "services" "monero" "rpc" "port" ])
    (mkAliasOptionModule
      [ "p2poolix" "monero" "rpc" "restricted" ]
      [ "services" "monero" "rpc" "restricted" ]
    )
    (mkAliasOptionModule
      [ "p2poolix" "monero" "rpc" "address" ]
      [ "services" "monero" "rpc" "address" ]
    )
    (mkAliasOptionModule
      [ "p2poolix" "monero" "limits" "upload" ]
      [ "services" "monero" "limits" "upload" ]
    )
    (mkAliasOptionModule
      [ "p2poolix" "monero" "limits" "threads" ]
      [ "services" "monero" "limits" "threads" ]
    )
    (mkAliasOptionModule
      [ "p2poolix" "monero" "limits" "syncSize" ]
      [ "services" "monero" "limits" "syncSize" ]
    )
    (mkAliasOptionModule
      [ "p2poolix" "monero" "limits" "download" ]
      [ "services" "monero" "limits" "download" ]
    )
  ];

  config = mkIf cfg.enable {
    services.monero = {
      enable = true;
    };
  };
}
