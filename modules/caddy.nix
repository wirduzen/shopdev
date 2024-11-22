{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.shopdev;
  hostConfig = ''
    @default {
      not path ${cfg.caddy.staticFilePaths}
      not expression header_regexp('xdebug', 'Cookie', 'XDEBUG_SESSION') || query({'XDEBUG_SESSION': '*'})
    }
    @debugger {
      not path ${cfg.caddy.staticFilePaths}
      expression header_regexp('xdebug', 'Cookie', 'XDEBUG_SESSION') || query({'XDEBUG_SESSION': '*'})
    }

    root * ./${cfg.caddy.documentRoot}

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
  '';
in
{
  options.shopdev.caddy = {
    additionalServerAlias = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = ''
        Additional server alias for caddy. Hostnames / IPs added here will be served by caddy.
      '';
      default = [ ];
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

    staticFilePaths = lib.mkOption {
      type = lib.types.str;
      description = ''Sets the matcher paths to be "ignored" by caddy'';
      default = "/theme/* /media/* /thumbnail/* /bundles/* /css/* /fonts/* /js/* /recovery/* /sitemap/*";
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
    services.caddy = {
      enable = true;
      config = ''
        {
          # disables HTTP-to-HTTPS redirects because we need http for profiling
          auto_https disable_redirects
          # disables install_trust because it needs additional packages that are not available.
          skip_install_trust
        }
      '';
      virtualHosts = {
        # this is a redirect to localhost to prevent issues with the licence checker
        "https://127.0.0.1".extraConfig = ''
          redir https://localhost{uri}
        '';
        "http://127.0.0.1".extraConfig = ''
          redir http://localhost{uri}
        '';
        # localhost without https is needed for profiling
        "http://localhost" = {
          serverAliases = cfg.caddy.additionalServerAlias;
          extraConfig = hostConfig;
        };
        # https://localhost is the main host
        "https://localhost" = {
          serverAliases = cfg.caddy.additionalServerAlias;
          extraConfig = lib.strings.concatStrings [
            ''
              tls internal
            ''
            hostConfig
          ];
        };
      };
    };
  };
}
