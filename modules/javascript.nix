{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.shopdev;
in
{
  config = lib.mkIf cfg.enable {
    languages.javascript = {
      enable = true;
      package = pkgs.nodejs-18_x;
    };

    env = {
      NODE_OPTIONS = "--openssl-legacy-provider --max-old-space-size=2000";
      # NPM_CONFIG_ENGINE_STRICT = "false"; # hotfix for npm10
    };
  };
}
