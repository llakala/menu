{ pkgs, localPackages, callPackage }:

localPackages.writeFishApplication {
  name = "imanpu"; # Inform Me About N Pins Updates

  runtimeInputs = builtins.attrValues {
    inherit (pkgs) jq;
    inherit (localPackages) revive;
    qwesu = callPackage ./qwesu/package.nix {};
  };

  text = builtins.readFile ./imanpu.fish;
}
