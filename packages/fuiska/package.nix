{ pkgs, llakaLib, localPackages, ... }:

let
  nixpkgsDeps = with pkgs;
  [
    jq
    git
  ];

  selfDeps = with localPackages;
  [
    hue
    fight
    revive
  ];

in llakaLib.writeFishApplication
{
  name = "fuiska"; # Flake Updates I Should Know About?
  runtimeInputs = nixpkgsDeps ++ selfDeps;

  text = builtins.readFile ./fuiska.fish;

}
