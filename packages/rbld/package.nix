{ pkgs, localPackages }:

localPackages.writeFishApplication {
  name = "rbld"; # Rebuild But Less Dumb

  runtimeInputs = builtins.attrValues {
    inherit (pkgs) nix-output-monitor git;
    nixos-rebuild = pkgs.nixos-rebuild;
    inherit (localPackages) hue revive;
  };

  text = builtins.readFile ./rbld.fish;
}
