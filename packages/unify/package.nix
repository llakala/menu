{ pkgs, localPackages, callPackage }:

localPackages.writeFishApplication {
  name = "unify"; # Update NixOS Inputs For Yourself

  runtimeInputs = builtins.attrValues {
    inherit (pkgs) git;
    inherit (localPackages) rbld hue revive;
    balc = callPackage ./balc/package.nix {};
  };

  text = builtins.readFile ./unify.fish;
}
