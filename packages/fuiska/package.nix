{ pkgs, localPackages }:

localPackages.writeFishApplication {
  name = "fuiska"; # Flake Updates I Should Know About?

  runtimeInputs = builtins.attrValues {
    inherit (pkgs) jq git;
    inherit (localPackages) hue fight revive;
  };

  text = builtins.readFile ./fuiska.fish;
}
