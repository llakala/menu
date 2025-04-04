{ pkgs, llakaLib, llakaPackages, localPackages }:

let
  nixpkgsDeps = with pkgs;
  [
    git
  ];

  selfDeps = with localPackages;
  [
    rbld
    hue
    balc
  ];

  llakaDeps = with llakaPackages;
  [
    revive
  ];

in llakaLib.writeFishApplication
{
  name = "unify"; # Update NixOS Inputs For Yourself
  runtimeInputs = nixpkgsDeps ++ selfDeps ++ llakaDeps;

  text = builtins.readFile ./unify.fish;
}
