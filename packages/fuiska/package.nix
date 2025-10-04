{ pkgs, llakaLib, llakaPackages, localPackages }:

llakaLib.writeFishApplication {
  name = "fuiska"; # Flake Updates I Should Know About?

  runtimeInputs = builtins.attrValues {
    inherit (pkgs) jq git;
    inherit (localPackages) hue fight;
    inherit (llakaPackages) revive;
  };

  text = builtins.readFile ./fuiska.fish;
}
