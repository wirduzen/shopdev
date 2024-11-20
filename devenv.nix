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
        There is really no reason to ever change this.
      '';
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

    dotenv.disableHint = true;

    # Set Shopware environment variables
    env = {
      APP_URL = "http://${cfg.host}:${toString cfg.httpPort}";
      #APP_SECRET = lib.mkDefault "devsecret";
      STOREFRONT_PROXY_URL = cfg.host;
      CYPRESS_baseUrl = "http://${cfg.host}:${toString cfg.httpPort}";
      SHOPWARE_CACHE_ID = "dev";
      PUPPETEER_SKIP_CHROMIUM_DOWNLOAD = true;
      DISABLE_ADMIN_COMPILATION_TYPECHECK = true;
    };
  };
}
