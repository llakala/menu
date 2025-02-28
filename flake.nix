{
  # Menu stands for: My Excellent NixOS Utils
  description = "Menu, a collection of NixOS utilities.";

  inputs =
  {
    # If you want to use `follows`, make it follow your own unstable input
    # for access to nixos-rebuild-ng
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    llakaLib =
    {
      url = "github:llakala/llakaLib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... } @ inputs:
  let
    lib = nixpkgs.lib;

    # The "normal" systems. If it ever doesn't work with one of these, or you want me
    # to add a system, let me know!
    supportedSystems = [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

    forAllSystems = function: lib.genAttrs
      supportedSystems
      (system: function nixpkgs.legacyPackages.${system});
  in
  {
    legacyPackages = forAllSystems
    (
      pkgs: let llakaLib = inputs.llakaLib.fullLib.${pkgs.system};
      in llakaLib.collectDirectoryPackages
      {
        inherit pkgs;
        directory = ./packages;

        extras = { inherit llakaLib; }; # Lets the packages rely on llakaLib
      }
    );

    devShells = forAllSystems
    (
      pkgs:
      {
        default = pkgs.mkShellNoCC
        {
          # Grab all packages provided by the flake. We expect there
          # won't be any subattrs. If they ever exist, we'd have to use
          # something recursive, but I hope they won't.
          packages = lib.attrValues self.legacyPackages.${pkgs.system};
        };
      }
    );

  };
}
