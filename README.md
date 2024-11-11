# shopdev

A development environment for Shopware, made by WIRDUZEN.

# Features

- Defaults are set for a "turnkey" config
- Commands are provided for easy setup

# Installation

Go to the [examples](https://github.com/wirduzen/shopdev/tree/main/examples) folder and download the `.envrc`, `devenv.nix` and `devenv.yaml` file. All you have to do is drop them into your project folder and you can start the configuration.

## Configuration

Once you've installed shopdev, you can start the Shop by running `devenv up`.

For the Shop to fully work you also have to do the usual setup, like `composer install` and building the Frontend. You can do these steps manually or use the `shopdev-init` command provided by shopdev: Open a `devenv shell` and run `shopdev-init` (Note that `devenv up` must be running in another terminal for this to work). This will do the following:

- Add the devenv, shopware and fossar caches
- Run `composer install` and additional composer commands
- Allows you to import a database dump
- Generates a JWT secret, which is needed to validate plugin licences with the Shopware API
- Run build-js

# Options

Shopdev provides custom options to make the setup easier. These options combine multiple [devenv options](https://devenv.sh/reference/options/) together and also set environment variables required by Shopware depending on your config. For a full list of options, see the [Wiki page](https://github.com/wirduzen/shopdev/wiki/Options).

These options come preconfigured with default values. You can find an explanation for these values [here](https://github.com/wirduzen/shopdev/wiki/Default-Settings). 

Sometimes it may be necessary to change a devenv option that is alreay set by Shopdev. In that case, you can override them using the `mkForce` syntax.
