{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.shopdev;

  package = inputs.nix-phps.packages.${pkgs.stdenv.system}.${cfg.php.package};

  phpPackage = package.buildEnv {
    extensions = { all, enabled }: with all; enabled
      ++ (lib.optional config.services.redis.enable redis)
      ++ (lib.optional config.services.blackfire.enable blackfire)
      ++ (lib.optional config.services.rabbitmq.enable amqp);
      #++ lib.attrsets.attrValues (lib.attrsets.getAttrs cfg.additionalPhpExtensions package.extensions);
    extraConfig = lib.strings.concatLines cfg.php.config;
  };

  phpXdebugPackage = package.buildEnv {
    extensions = { all, enabled }: with all; enabled
      ++ [ xdebug grpc ]
      ++ (lib.optional config.services.redis.enable redis)
      ++ (lib.optional config.services.rabbitmq.enable amqp);
      #++ lib.attrsets.attrValues (lib.attrsets.getAttrs cfg.additionalPhpExtensions package.extensions);
    extraConfig = lib.strings.concatLines cfg.php.config;
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
    memoryLimit = lib.mkOption {
      type = lib.types.str;
      description = ''
        Memory Limit for PHP
      '';
      example = [
        "8192M"
        "6G"
        "-1"
      ];
      default = "8192M";
    };
    config = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''PHP settings.'';
      default = [
        "pdo_mysql.default_socket = ${builtins.toString cfg.database.port}"
        "mysqli.default_socket = ${builtins.toString cfg.database.port}"
        "memoryLimit = ${cfg.php.memoryLimit}"
        # "blackfire.agent_socket = "${config.services.blackfire.socket}";" # blackfire is not included in shopdev
        ''
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
      ];
    };
#     maxExecutionTime = lib.mkOption {
#       type = lib.types.int;
#       description = '''';
#       default = 2;
#     };

#     extraConfig = lib.mkOption {
#       type = lib.types.str;
#       description = "Additional php.ini configuration. This is passed to phpPackage = pkgs.php.buildEnv.extraConfig";
#       default = "";
#       example = ''
#         memory_limit = 0
#       '';
#     };
  };
  config = lib.mkIf cfg.enable {
    # what does this do?
    # Example command to use Xdebug with CLI inside devenv shell
    # export XDEBUG_MODE=debug XDEBUG_SESSION=1; export XDEBUG_CONFIG="idekey=PHPSTORM"; php bin/console theme:compile
    scripts.debug.exec = ''
      XDEBUG_SESSION=1 ${phpXdebugPackage}/bin/php "$@"
    '';
    languages.php = {
      enable = true;
      package = phpPackage;
      # ini = lib.strings.concatStrings cfg.php.config;
      fpm = {
#         phpOptions = ''
#           memory_limit = "${cfg.php.memoryLimit}"
#         '';

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
