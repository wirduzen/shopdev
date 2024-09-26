{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.shopdev;
in
{
  options.shopdev = {
    redis = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable redis";
        default = true;
      };
      host = lib.mkOption {
        type = lib.types.str;
        description = ''Redis host. Defaults to global host.'';
        default = cfg.host;
      };
      port = lib.mkOption {
        type = lib.types.int;
        description = ''Sets the Redis port'';
        default = 6379;
      };
    };

    adminer = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Adminer";
        default = false;
      };
      host = lib.mkOption {
        type = lib.types.str;
        description = ''Adminer host. Defaults to global host.'';
        default = cfg.host;
      };
      port = lib.mkOption {
        type = lib.types.int;
        description = ''Sets the Adminer port'';
        default = 8010;
      };
    };

    mailhog = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = "Enable Mailhog";
        default = false;
      };
      host = lib.mkOption {
        type = lib.types.str;
        description = ''Mailhog host. Defaults to global host.'';
        default = cfg.host;
      };
      port = lib.mkOption {
        type = lib.types.int;
        description = ''Sets the Mailhog Web UI port'';
        default = 8025;
      };
      apiPort = lib.mkOption {
        type = lib.types.int;
        description = ''Sets the Mailhog API port'';
        default = 8025;
      };
      smtpPort = lib.mkOption {
        type = lib.types.int;
        description = ''Sets the Mailhog SMTP port'';
        default = 1025;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.redis = lib.mkIf cfg.redis.enable {
      enable = true;
      bind = cfg.redis.host;
      port = cfg.redis.port;
    };

    services.adminer = lib.mkIf cfg.adminer.enable {
      enable = true;
      listen = "${cfg.adminer.host}:${toString cfg.adminer.port}";
    };

    services.mailhog = lib.mkIf cfg.mailhog.enable {
      enable = true;
      uiListenAddress = "${cfg.mailhog.host}:${toString cfg.mailhog.port}";
      apiListenAddress = "${cfg.mailhog.host}:${toString cfg.mailhog.apiPort}";
      smtpListenAddress = "${cfg.mailhog.host}:${toString cfg.mailhog.smtpPort}";
    };

    env = lib.mkMerge [
      # Redis Environment Variables
      (lib.mkIf cfg.redis.enable {
        REDIS_DSN = "redis://${cfg.redis.host}:${toString cfg.redis.port}";
        REDIS_SESSION_HOST = cfg.redis.host;
        REDIS_SESSION_PORT = cfg.redis.port;
        SHOPWARE_REDIS_SESSION_HOST = cfg.redis.host;
        SHOPWARE_REDIS_SESSION_PORT = cfg.redis.port;
        # no idea what it does
        # SHOPWARE_REDIS_SESSION_ENABLED="0"
        # Redis Cache
        REDIS_CACHE_HOST = cfg.redis.host;
        REDIS_CACHE_PORT = cfg.redis.port;
        SHOPWARE_REDIS_CACHE_HOST = cfg.redis.host;
        SHOPWARE_REDIS_CACHE_PORT = cfg.redis.port;
        SHOPWARE_REDIS_CACHE_ENABLED = "1";
        # no idea what it does
        SHOPWARE_REDIS_CACHE_PREFIX = "dev";
      })
      # Mailhog Environment Variables
      (lib.mkIf cfg.mailhog.enable {
        # deprecated: With Shopware 6.4.17.0 the MAILER_DSN variable will be used in this template instead of MAILER_URL
        MAILER_URL = "smtp://${cfg.mailhog.host}:${toString cfg.mailhog.smtpPort}?encryption=&auth_mode=";
        MAILER_DSN = "smtp://${cfg.mailhog.host}:${toString cfg.mailhog.smtpPort}?encryption=&auth_mode=";
      })
    ];
  };
}
