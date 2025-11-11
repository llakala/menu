{
  # Menu stands for: My Excellent NixOS Utils
  description = "Menu, a collection of NixOS utilities.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
  let
    lib = nixpkgs.lib;

    forAllSystems = function: lib.genAttrs
      [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ]
      (system: function nixpkgs.legacyPackages.${system} system);
  in {
    # Stored in a separate file, if you'd prefer to be flakeless
    legacyPackages = forAllSystems (pkgs: _:import ./packages/default.nix { inherit pkgs; });

    devShells = forAllSystems (pkgs: system: {
      default = pkgs.mkShellNoCC {
        packages = builtins.attrValues {
          inherit (self.legacyPackages.${system})
            fuiska
            rbld
            imanpu
            unify;
        };
      };
      }
    );
  };
}
