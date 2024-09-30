{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.shopdev;

  package = inputs.nix-phps.packages.${pkgs.stdenv.system}.${cfg.php.package};

  phpPackage = package.buildEnv {
    extensions = { all, enabled }: with all; enabled
      ++ (lib.optional config.services.redis.enable redis)
      ++ (lib.optional config.services.blackfire.enable blackfire)
      ++ (lib.optional config.services.rabbitmq.enable amqp)
      ++ lib.attrsets.attrValues (lib.attrsets.getAttrs cfg.php.additionalExtensions package.extensions);
    extraConfig = lib.strings.concatLines [ cfg.php.defaultConfig cfg.php.extraConfig ];
  };

  phpXdebugPackage = package.buildEnv {
    extensions = { all, enabled }: with all; enabled
      ++ [ xdebug grpc ]
      ++ (lib.optional config.services.redis.enable redis)
      ++ (lib.optional config.services.rabbitmq.enable amqp)
      ++ lib.attrsets.attrValues (lib.attrsets.getAttrs cfg.php.additionalExtensions package.extensions);
    extraConfig = lib.strings.concatLines [ cfg.php.defaultConfig cfg.php.extraConfig ];
  };
in
{
  options.shopdev.php = {
    package = lib.mkOption {
      type = lib.types.str;
      description = ''
        Set the PHP Package to use.
        Packages are provided by fossar/nix-phps, see https://github.com/fossar/nix-phps for all available versions.
      '';
      default = "php83";
    };
    defaultConfig = lib.mkOption {
      type = lib.types.str;
      description = ''
        The default PHP settings. You can override these using shopdev.php.extraConfig.
        The settings are passed to the custom PHP package instead of php.ini.
      '';
      default = lib.strings.concatStrings [
        ''
          pdo_mysql.default_socket = ${builtins.toString cfg.database.port}
          mysqli.default_socket = ${builtins.toString cfg.database.port}
          memory_limit = 512M
          realpath_cache_ttl = 3600
          session.gc_probability = 0
          display_errors = On
          display_startup_errors = true
          error_reporting = E_ALL
          html_errors = true
          max_execution_time = 60
          max_input_time = 60
          assert.active = 0
          zend.detect_unicode = 0
          opcache.memory_consumption = 256M
          opcache.interned_strings_buffer = 20
          opcache.enable_cli = 1
          opcache.enable = 1
          zend.assertions = 0
          short_open_tag = 0
          xdebug.mode = "debug"
          xdebug.start_with_request = "trigger"
          xdebug.discover_client_host = 1
          xdebug.var_display_max_depth = -1
          xdebug.var_display_max_data = -1
          xdebug.var_display_max_children = -1
        ''
        (lib.strings.optionalString cfg.blackfire.enable ''
          blackfire.agent_socket = ${builtins.toString cfg.blackfire.socket}
        '')
      ];
    };
    extraConfig = lib.mkOption {
      type = lib.types.str;
      description = ''
        Additional PHP settings. The settings here will override settings in shopdev.php.defaultConfig.
      '';
      default = "";
      example = ''
        memory_limit = 1024M
      '';
    };
    additionalExtensions = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Additional PHP extensions";
      default = [ ];
      example = [ "mailparse" ];
    };
  };

  config = lib.mkIf cfg.enable {
    languages.php = {
      enable = true;
      package = phpPackage;
      fpm = {
        pools = {
          web = {
            phpPackage = phpPackage;
            settings = {
              "clear_env" = "no";
              "pm" = "dynamic";
              "pm.max_children" = 10;
              "pm.start_servers" = 2;
              "pm.min_spare_servers" = 1;
              "pm.max_spare_servers" = 10;
            };
          };
          xdebug = {
            phpPackage = phpXdebugPackage;
            settings = {
              "clear_env" = "no";
              "pm" = "dynamic";
              "pm.max_children" = 10;
              "pm.start_servers" = 2;
              "pm.min_spare_servers" = 1;
              "pm.max_spare_servers" = 10;
            };
          };
        };
      };
    };
  };
}
