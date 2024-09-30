{ pkgs, config, inputs, lib, ... }:

let
  cfg = config.shopdev;

  vhostConfig = lib.strings.concatStrings [
    ''
      @default {
        not path ${cfg.caddy.staticFilePaths}
        not expression header_regexp('xdebug', 'Cookie', 'XDEBUG_SESSION') || query({'XDEBUG_SESSION': '*'})
      }
      @debugger {
        not path ${cfg.caddy.staticFilePaths}
        expression header_regexp('xdebug', 'Cookie', 'XDEBUG_SESSION') || query({'XDEBUG_SESSION': '*'})
      }

      root * ${cfg.caddy.projectRoot}/${cfg.caddy.documentRoot}

      @fallbackMediaPaths {
        path ${cfg.caddy.fallbackMediaPaths}
      }

      handle @fallbackMediaPaths {
        ${lib.strings.optionalString (cfg.caddy.fallbackMediaUrl != "") ''
        @notStatic not file
        redir @notStatic ${lib.strings.removeSuffix "/" cfg.caddy.fallbackMediaUrl}{path}
        ''}
        file_server
      }

      handle_errors {
        respond "{err.status_code} {err.status_text}"
      }

      handle {
        php_fastcgi @default unix/${config.languages.php.fpm.pools.web.socket} {
          index ${cfg.caddy.indexFile}
          trusted_proxies private_ranges
        }

        php_fastcgi @debugger unix/${config.languages.php.fpm.pools.xdebug.socket} {
          index ${cfg.caddy.indexFile}
          trusted_proxies private_ranges
        }

        file_server

        encode zstd gzip
      }

      log {
        output stderr
        format console
        level ERROR
      }
    ''
    # cfg.additionalVhostConfig
  ];

  vhostConfigTls = lib.strings.concatStrings [
    ''
      tls internal
    ''
    vhostConfig
  ];

  vhostDomains = lib.lists.unique ([ cfg.host "localhost" "127.0.0.1" ] ++ cfg.caddy.additionalServerAlias);

  caddyHostConfig = (lib.mkMerge
    (lib.forEach vhostDomains (domain: {
      "http://${toString domain}:${toString cfg.httpPort}" = lib.mkDefault {
        extraConfig = vhostConfig;
      };
      "https://${toString domain}:${toString cfg.httpsPort}" = lib.mkDefault {
        extraConfig = vhostConfigTls;
      };
    }))
  );
in {
  options.shopdev.caddy = {
    additionalServerAlias = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        Additional server alias for caddy. Hostnames / IPs added here will be served by caddy.
      '';
      default = [ ];
    };

    staticFilePaths = lib.mkOption {
      type = lib.types.str;
      description = ''Sets the matcher paths to be "ignored" by caddy'';
      default = "/theme/* /media/* /thumbnail/* /bundles/* /css/* /fonts/* /js/* /recovery/* /sitemap/*";
    };

    documentRoot = lib.mkOption {
      type = lib.types.str;
      description = "Sets the docroot of caddy";
      default = "public";
    };

    indexFile = lib.mkOption {
      type = lib.types.str;
      description = "Sets the caddy index file for the document root";
      default = "index.php";
    };

    projectRoot = lib.mkOption {
      type = lib.types.str;
      description = "Root of the project as path from the file devenv.nix";
      default = ".";
      example = "project";
    };

    fallbackMediaUrl = lib.mkOption {
      type = lib.types.str;
      description = ''Fallback URL for media not found on local storage. Best for CDN purposes without downloading them.'';
      default = "";
    };

    fallbackMediaPaths = lib.mkOption {
      type = lib.types.str;
      description = ''Sets the paths to be redirected to the fallbackMediaUrl.'';
      default = "/media/* /thumbnail/*";
    };
  };

  config = lib.mkIf cfg.enable {
    # Installs a certificate into local trust store(s)
    scripts.caddy-trust.exec = ''
      ${config.services.caddy.package}/bin/caddy trust
    '';
    services.caddy = {
      enable = true;
      # what is this config?
      config = ''
        {
          auto_https disable_redirects
          skip_install_trust
        }
      '';
      virtualHosts = caddyHostConfig;
    };
  };
}
