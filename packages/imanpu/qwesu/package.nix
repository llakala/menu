{ pkgs, localPackages }:

localPackages.writeFishApplication {
  name = "qwesu"; # Query Whether Each Source Updated

  runtimeInputs = builtins.attrValues {
    inherit (pkgs) jq git xq-xml;
  };

  text = builtins.readFile ./qwesu.fish;
}
