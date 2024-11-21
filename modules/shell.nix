{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.shopdev;
in
{
  options.shopdev = {
    composer.authCommand = lib.mkOption {
        type = lib.types.str;
        description = ''
          Enter a command that will be run by shopdev-createAuth.
          The output will be piped into auth.json.
        '';
        default = "";
      };
  };
  config = lib.mkIf cfg.enable {
    enterShell = ''
      printf '\n\nHello World from ShopDev made by WIRDUZEN!\n'
      printf 'If this is your first time running this shop, consider running "shopdev-init" to finish the setup and "shopdev-createAuth" to create the auth.json from the configured command.\n'
    '';

    scripts = {
      createOptionsDocs.exec = ''
        nix build -f modules/mkDocs.nix
        cat result > ../docs/options.md
      '';

      # see https://github.com/NixOS/nixpkgs/blob/nixos-24.05/nixos/modules/services/web-servers/nginx/default.nix
      # service definition: AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" "CAP_SYS_RESOURCE" ]
      allowPorts.exec = ''
        echo "THIS IS NOT A GOOD SOLUTION AND HAS TO BE CHANGED ASAP!"
        echo "sudo sysctl -w net.ipv4.ip_unprivileged_port_start=80"
        sudo sysctl net.ipv4.ip_unprivileged_port_start=80
        #echo "This will allow caddy to bind to port 80";
        #sudo setcap CAP_NET_BIND_SERVICE=+eip ${config.services.caddy.package}/bin/caddy;
      '';

      shopware-install.exec = ''
        bin/console system:install --basic-setup --create-database --force
        echo "Shopware has been installed. Open http://localhost:8000/admin in your browser after the installation has finished. You should see the Shopware admin interface.The default credentials are:"
        echo "User: admin"
        echo "Password: shopware"
      '';

      shopdev-import-database.exec = ''
        echo "Importing database dump..."
        echo -n "Enter path to database dump (myDatabase.sql): "
        read DBPATH
        echo "Please make sure that this is the right database: $DBPATH"
        echo -n "Type 'CONFIRM' to start the import process: "
        read confirm
        if [ $confirm = "CONFIRM" ]
        then
          echo "Confirmed, importing DB..."
          mysql -u ${cfg.database.username} -p${cfg.database.password} ${cfg.database.name} < $DBPATH
          echo "Imported DB"
        else
          echo "No confirmation, not importing DB"
        fi
      '';

      shopdev-init.exec = ''
        # create install.lock so that shopware does not install itself again
        touch install.lock

        # Before installing devenv, instruct Cachix to use the devenv cache:
        cachix use devenv
        # Before booting up your development environment, configure Cachix to use Shopware's cache:
        cachix use shopware
        # use cachix cache for fossar php packages to avoid building those PHP packages yourself.
        cachix use fossar

        echo "Running <composer install> ..."
        composer install

        echo "generate jwt secret"
        bin/console system:generate-jwt-secret

        echo "build js"
        bin/build-js.sh
      '';

      shopdev-createAuth.exec = ''
        echo "Creating auth.json..."
        json=$(${config.shopdev.composer.authCommand});
        if [ -n "$json" ]; then
          echo $json > auth.json;
          echo "Created auth.json."
        else
          echo "No Content for auth.json provided. Make sure the shopdev.composer.authCommand produces the correct string."
        fi
      '';
    };
  };
}
