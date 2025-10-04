{ pkgs, llakaLib, llakaPackages, localPackages }:

llakaLib.writeFishApplication {
  name = "unify"; # Update NixOS Inputs For Yourself

  runtimeInputs = builtins.attrValues {
    inherit (pkgs) git;
    inherit (localPackages) rbld hue balc;
    inherit (llakaPackages) revive;
  };

  text = builtins.readFile ./unify.fish;
}
