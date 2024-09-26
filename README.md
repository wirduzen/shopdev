# shopdev

A development environment for Shopware, made by WIRDUZEN.

# Features

- Defaults are set for a "turnkey" config
- Commands are provided for easy setup

# Installation

Depending on your usecase, there are some differences in the installation procedure.

## for an existing shop 

Open a terminal in the shop folder and run `devenv init` to create the initial devenv structure. This will create a devenv.yaml, which should look something like this:

```devenv
inputs:
  nixpkgs:
    url: github:cachix/devenv-nixpkgs/rolling
```

Now you have to add shopdev as an input to `devenv.yaml`:

```devenv
allowUnfree: true
imports:
  - shopdev
inputs:
  nixpkgs:
    url: github:cachix/devenv-nixpkgs/rolling
  shopdev:
    url: github:wirduzen/shopdev/test
    flake: false
```

create install.lock file

## for a new shop

## as a flake input

# Configuration

Once you've installed shopdev, you can start using it either by downloading one of the example configurations or just by adding `shopdev.enable = true;` to your `devenv.nix` and adding other options from the documentation.

After that you should open a shell (using `devenv shell`) and run `shopdev-init`. This will do some configuration for you:

- adds caches to cachix: devenv, shopware, fossar
- runs `composer install` and additional composer commands
- allows you to import a database dump
- generates jwt secret: Authentication for shopware api to validate plugin licences
- runs build-js

## Example Configurations

You can download one of the examples from https://github.com/wirduzen/shopdev/blob/main/examples/sw6_example.nix, or 

Go to the Download the `sw6_example.nix` and open it. 
