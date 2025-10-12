{ pkgs ? import <nixpkgs> {} }:

let
  # See https://nix.dev/tutorials/callpackage.html#interdependent-package-sets
  # Lets packages rely on each other easily
  callPackage = pkgs.lib.callPackageWith (pkgs // {
    localPackages = packages;
    inherit callPackage; # I love laziness!
  });

  packages = {
    fuiska = callPackage ./fuiska/package.nix {};
    hue = callPackage ./hue/package.nix {};
    imanpu = callPackage ./imanpu/package.nix {};
    rbld = callPackage ./rbld/package.nix {};
    revive = callPackage ./revive/package.nix {};
    unify = callPackage ./unify/package.nix {};
    writeFishApplication = callPackage ./writeFishApplication/package.nix {};
  };

in packages
