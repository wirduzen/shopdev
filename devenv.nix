{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.shopdev;
in
{
  imports = [
    ./modules/database.nix
    ./modules/php.nix
    ./modules/javascript.nix
    ./modules/rabbitmq.nix
    ./modules/search.nix
    ./modules/services.nix
    ./modules/caddy.nix
    ./modules/shell.nix # custom commands and routines
  ];

  options.shopdev = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enables ShopDev, a development environment for Shopware.";
      default = false;
    };
    host = lib.mkOption {
      type = lib.types.str;
      description = ''
        This is the host that all services use (unless overridden via their specific host option).
        Defaults to localhost.
        There is really no reason to ever change this.
      '';
      default = "localhost";
    };
    domainName = lib.mkOption {
      type = lib.types.str;
      description = ''Domain name. Defaults to localhost'';
      default = "localhost";
    };
    httpPort = lib.mkOption {
      type = lib.types.int;
      description = ''Sets the HTTP port'';
      default = 80;
    };
    httpsPort = lib.mkOption {
      type = lib.types.int;
      description = ''Sets the HTTPS port'';
      default = 443;
    };
  };

  config = lib.mkIf cfg.enable {
    packages = [
      pkgs.jq
      pkgs.gnused
      pkgs.gnupatch
    ];

    # dotenv is weird and does not work; YES IT DOES!!!
    # phpVersion = if builtins.hasAttr "PHP_VERSION" config.env then config.env.PHP_VERSION else cfg.phpVersion;
    # echo "PHP Version from .env file: ${config.env.APP_ENV}"
    # dotenv.disableHint = true;
    dotenv.enable = true;

    # Set Shopware environment variables
    env = {
      APP_ENV = "dev"; # set Shopware into dev mode. Will lead to error 500 if not set
      APP_URL = "https://${cfg.host}:${toString cfg.httpPort}"; # no idea
      #APP_SECRET = lib.mkDefault "devsecret";
      STOREFRONT_PROXY_URL = cfg.host;
      CYPRESS_baseUrl = "http://${cfg.host}:${toString cfg.httpPort}";
      SHOPWARE_CACHE_ID = "dev";
      PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true;
      DISABLE_ADMIN_COMPILATION_TYPECHECK = true;
    };
  };
}
