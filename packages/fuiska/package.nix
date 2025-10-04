{ pkgs, llakaLib, llakaPackages, localPackages }:

let
  nixpkgsDeps = with pkgs; [
    jq
    git
  ];

  selfDeps = with localPackages; [
    hue
    fight
  ];

  llakaDeps = with llakaPackages; [
    revive
  ];

in llakaLib.writeFishApplication {
  name = "fuiska"; # Flake Updates I Should Know About?
  runtimeInputs = nixpkgsDeps ++ selfDeps ++ llakaDeps;

  text = builtins.readFile ./fuiska.fish;
}
