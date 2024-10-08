{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.shopdev;
in
{
  options.shopdev.database = {
    host = lib.mkOption {
      type = lib.types.str;
      description = ''Database host.'';
      default = cfg.host;
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = ''
        Sets the MySQL port.
      '';
      default = 3306;
    };
    name = lib.mkOption {
      type = lib.types.str;
      description = ''Database name'';
      default = "shopware";
    };
    username = lib.mkOption {
      type = lib.types.str;
      description = ''Database username'';
      default = "shopware";
    };
    password = lib.mkOption {
      type = lib.types.str;
      description = ''Database user password'';
      default = "shopware";
    };
  };

  config = lib.mkIf cfg.enable {
    env = {
      DATABASE_URL = "mysql://${cfg.database.username}:${cfg.database.password}@${cfg.database.host}:${toString cfg.database.port}/${cfg.database.name}"; # Used by Symfony
      SQL_SET_DEFAULT_SESSION_VARIABLES = "0"; # Don't know what it does, Felix said to remove it
      # see kellerkinder doku: We're setting some environment variables as default. As example, we're setting SQL_SET_DEFAULT_SESSION_VARIABLES default to O, since we're having the shopware recommended configuration for the database.
    };
    services.mysql = {
      enable = true;
      package = pkgs.mysql80;
      initialDatabases = [
        { name = cfg.database.name; }
      ];
      ensureUsers = [
        # create shopware user
        {
          name = cfg.database.username;
          password = cfg.database.password;
          ensurePermissions = { "*.*" = "ALL PRIVILEGES"; };
        }
      ];
      settings = let
        SQL_Config = {
          user = "${cfg.database.username}";
          password = "${cfg.database.password}";
          host = "${cfg.database.host}";
        };
      in {
        mysqld = {
          group_concat_max_len = 32000;
          key_buffer_size = 16777216;
          max_allowed_packet = 134217728;
          table_open_cache = 1024;
          port = cfg.database.port;
          sql_mode = "STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION";
          skip_log_bin = 1;
        };

        # mysql binaries
        mysql = SQL_Config;
        mysqldump = SQL_Config;
        mysqladmin = SQL_Config;
      };
    };
  };
}
