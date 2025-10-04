{ pkgs, llakaLib, lib, localPackages }:

assert lib.assertMsg (pkgs ? nixos-rebuild-ng) ''
  RBLD relies on nixos-rebuild-ng, but it wasn't found in pkgs.
  This likely means you made Menu follow an older nixpkgs version, which doesn't have nixos-rebuild-ng.
  Instead, have Menu follow a more recent nixpkgs version.
'';

llakaLib.writeFishApplication {
  name = "rbld"; # Rebuild But Less Dumb

  runtimeInputs = builtins.attrValues {
    inherit (pkgs) nix-output-monitor git;
    nixos-rebuild = pkgs.nixos-rebuild-ng.override { nix = pkgs.lix; };
    inherit (localPackages) hue revive;
  };

  text = builtins.readFile ./rbld.fish;
}
