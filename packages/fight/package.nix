{ pkgs, localPackages }:

localPackages.writeFishApplication {
  name = "fight"; # Flake Input Gets Hash Tested
  runtimeInputs = with pkgs; [
    git
    jq
    ripgrep
  ];

  text = builtins.readFile ./fight.fish;
}
