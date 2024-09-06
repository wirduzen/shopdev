{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.shopdev;
in
{
  options.shopdev.search = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable search via OpenSearch";
      default = false;
    };
    useElasticSearch = lib.mkOption {
      type = lib.types.bool;
      description = "use ElasticSearch instead of OpenSearch";
      default = false;
    };
    host = lib.mkOption {
      type = lib.types.str;
      description = ''Search Engine host. Defaults to global host.'';
      default = cfg.host;
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = ''Sets the Elasticsearch/OpenSearch port'';
      default = 9200;
    };
    tcpPort = lib.mkOption {
      type = lib.types.int;
      description = ''Sets the Elasticsearch/OpenSearch TCP port'';
      default = 9300;
    };
  };

  config = lib.mkIf cfg.search.enable {
    services =
    if cfg.search.useElasticSearch
    then {
      elasticsearch = {
        enable = true;
        port = cfg.search.port;
        tcp_port = cfg.search.tcpPort;
      };
    }
    else {
      opensearch = {
        enable = true;
        settings = {
          "http.port" = cfg.search.port;
          "transport.port" = cfg.search.tcpPort;
        };
      };
    };

    env = {
      # Elasticsearch/Opensearch Environment Variables
      SHOPWARE_ES_ENABLED = "1";
      SHOPWARE_ES_INDEXING_ENABLED = "1";
      SHOPWARE_ES_INDEX_PREFIX = "sw";
      SHOPWARE_ES_HOSTS = "${cfg.search.host}:${toString cfg.search.port}";
      OPENSEARCH_URL = "${cfg.search.host}:${toString cfg.search.port}";
      # no idea what it does
      # SHOPWARE_ES_THROW_EXCEPTION = "1";
    };
  };
}
