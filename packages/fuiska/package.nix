{ pkgs, localPackages, callPackage }:

localPackages.writeFishApplication {
  name = "fuiska"; # Flake Updates I Should Know About?

  runtimeInputs = builtins.attrValues {
    inherit (pkgs) jq git;
    inherit (localPackages) hue revive;
    fight = callPackage ./fight/package.nix {};
  };

  text = builtins.readFile ./fuiska.fish;
}
