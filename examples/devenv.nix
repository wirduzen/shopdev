{ pkgs, config, inputs, lib, ... }:
{
  shopdev = {
    enable = true;
  };
  process.manager.implementation = "honcho";
}
