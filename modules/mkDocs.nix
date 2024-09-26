{
  nixpkgs ?
    builtins.fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/tarball/aa94fc78b0a49ed2a4a69b6f5082a1b286dd392d";
      sha256 = "1gkm7r07aqiyfgr32bzjmhvgsd543m2g3m43janmb6z1hz17ks1n";
    },
  pkgs ? import nixpkgs {},
}:
let
    # evaluate our options
    evalOptions = pkgs.lib.evalModules {
      check = false;
        modules = [
          ../flake.nix
          ./modules/database.nix
          ./modules/php.nix
          ./modules/javascript.nix
          ./modules/rabbitmq.nix
          ./modules/search.nix
          ./modules/services.nix
          ./modules/caddy.nix
          ./modules/shell.nix # custom commands and routines
        ];
    };
    # generate our docs
    optionsDoc = pkgs.nixosOptionsDoc {
        #inherit (evalOptions) options;
        options = builtins.removeAttrs evalOptions.options ["_module"];
    };
in
    # create a derivation for capturing the markdown output
#     runCommand "options-doc.md" {} ''
#         cat ${optionsDoc.optionsCommonMark} >> $out
#     ''
optionsDoc.optionsCommonMark

