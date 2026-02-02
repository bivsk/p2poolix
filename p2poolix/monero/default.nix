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
    optionalString
    types
    ;

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

  options.p2poolix.monero = {
    limits.peers = {
      incoming = mkOption {
        type = types.int;
        default = 64;
        description = ''
          Maximum number of incoming connections to other nodes.
          If your network connection's upload bandwidth is less than 10 Mbit,
          use a value of 16 instead.
        '';
      };
      outgoing = mkOption {
        type = types.int;
        default = 32;
        description = ''
          Maximum number of outgoing connections to other nodes.
          If your network connection's upload bandwidth is less than 10 Mbit,
          use a value of 8 instead.
        '';
      };
    };
    zmq = {
      address = mkOption {
        type = types.str;
        default = cfg.rpc.address;
        description = ''
          IP for ZMQ RPC server to listen on.
          This is required by p2pool.
        '';
      };
      port = mkOption {
        type = types.port;
        default = 18083;
        description = ''
          Port for ZMQ RPC server to listen on.
          This is required by p2pool.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    services.monero.enable = true;

    # and in/out peers
    services.monero.extraConfig = ''
      # Set connection limits as suggested by p2pool
      in-peers=${toString cfg.limits.peers.incoming}
      out-peers=${toString cfg.limits.peers.outgoing}

      # Ensure a few good working nodes
      add-priority-node=p2pmd.xmrvsbeast.com:18080
      add-priority-node=nodes.hashvault.pro:18080
    ''
    + optionalString p2poolix.p2pool.enable ''
      zmq-pub=tcp://${cfg.zmq.address}:${toString cfg.zmq.port}

      # Combat selfish miners and bad nodes
      enforce-dns-checkpointing=1
      enable-dns-blocklist=1
    '';
  };
}
