{ pkgs, llakaLib, localPackages }:

llakaLib.writeFishApplication {
  name = "unify"; # Update NixOS Inputs For Yourself

  runtimeInputs = builtins.attrValues {
    inherit (pkgs) git;
    inherit (localPackages) rbld hue balc revive;
  };

  text = builtins.readFile ./unify.fish;
}
