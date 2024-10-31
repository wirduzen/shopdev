# https://nixos-modules.nix.xn--q9jyb4c/lessons/option-documentation/lesson/
# nix build -f mkDocs.nix && cat result >> options.md
{
  nixpkgs ? builtins.fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/tarball/aa94fc78b0a49ed2a4a69b6f5082a1b286dd392d";
    sha256 = "1gkm7r07aqiyfgr32bzjmhvgsd543m2g3m43janmb6z1hz17ks1n";
  },
  pkgs ? import nixpkgs {}
}:
let
  evalOptions = pkgs.lib.evalModules {
    specialArgs = { inherit pkgs; };
    check = false;
    modules = [ ./devenv.nix ];
  };
  # generate our docs
  optionsDoc = pkgs.nixosOptionsDoc {
    options = builtins.removeAttrs evalOptions.options ["_module"];
  };
in
  # create a derivation for capturing the markdown output
  pkgs.runCommand "options-doc.md" {} ''
    cat ${optionsDoc.optionsCommonMark} >> $out
  ''
