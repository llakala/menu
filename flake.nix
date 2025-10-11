{
  # Menu stands for: My Excellent NixOS Utils
  description = "Menu, a collection of NixOS utilities.";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }:
  let
    lib = nixpkgs.lib;

    forAllSystems = function: lib.genAttrs
      [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ]
      (system: function nixpkgs.legacyPackages.${system});
  in {
    # Stored in a separate file, if you'd prefer to be flakeless
    legacyPackages = forAllSystems (pkgs: import ./packages/default.nix { inherit pkgs; });

    devShells = forAllSystems (pkgs: {
      default = pkgs.mkShellNoCC {
        packages = builtins.attrValues {
          inherit (self.legacyPackages.${pkgs.system})
            fuiska
            rbld
            imanpu
            unify;

          # Packages for devshell UX. nixpkgs provides gitMinimal by default these
          # days, which doesn't provide stuff like `git send-email`, which is used by
          # a contributor for sending patches without Github.
          inherit (pkgs) git;
        };
      };
      }
    );
  };
}
