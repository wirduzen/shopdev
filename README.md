# shopdev

A development environment for Shopware, made by WIRDUZEN.

# Features

- Defaults are set for a "turnkey" config
- Commands are provided for easy setup

# Installation

Go to the [examples](https://github.com/wirduzen/shopdev/tree/main/examples) folder and download the `.envrc`, `devenv.nix` and `devenv.yaml` file. All you have to do is drop them into your project folder and you can start the configuration.

## Configuration

Once you've installed shopdev, you can start the Shop by running `devenv up`.

For the Shop to fully work you also have to do the usual setup, like `composer install` and building the Frontend. You can do these steps manually or use the `shopdev-init` command provided by shopdev. Just open a `devenv shell` and run `shopdev-init` (Note that `devenv up` must be running in another terminal for this to work). This will do the following:

- adds caches to cachix: devenv, shopware, fossar
- runs `composer install` and additional composer commands
- allows you to import a database dump
- generates jwt secret: Authentication for shopware api to validate plugin licences
- runs build-js

# Options

For a full list of options, see the [Wiki page](https://github.com/wirduzen/shopdev/wiki/Options).

Shopdev provides custom options to make the setup easier. These options combine multiple [devenv options](https://devenv.sh/reference/options/) together and also set environment variables required by Shopware depending on your config. Because shopdev options just set values for devenv options, you can override them using the `mkForce` syntax.
