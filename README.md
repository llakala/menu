# Menu
This repository contains QOL scripts I've written for NixOS, specifically surrounding rebuilding and updating flake inputs.

## unify

`unify`, or "Update NixOS Inputs For Yourself", is a wrapper around `nix flake update`. Its primary feature is its
**Important Inputs** list -- you can specify which inputs you find important enough to trigger a `flake.lock` update
commit. For example, you'd probably want to update your `flake.lock` for `nixpkgs`, but you might not care about making
a whole update commmit just for `firefox-addons`. Unify attempts to automate this, so you can simply run it, and it'll
only go through the motions if the updates are "worth it".

Several other features are provided, to serve the goal of `unify` automatically doing the common parts of the flake
update process. These include:

- Automatically swapping branches to whatever branches you specify as your **primary branch**, so you don't accidentally
  commit `flake.lock` changes on a feature branch
- Ensuring that the system rebuilds without failure before committing
- Reverting any state created during execution. If the `flake.lock` changes didn't update any **important inputs**, it
  will revert the changes to the `flake.lock`. It will also automatically transfer you back onto your feature branch,
  if you were on one before starting execution.

## fuiska

`fuiska`, or "Flake Updates I Should Know About?", serves to quickly tell you which flake inputs have been updated. `nix
flake update` takes a long time to run, especially as your number of inputs grows. This is because it doesn't just check
whether a given input *has* updated - it also actually fetches the new commit data. `fuiska` just checks whether the
hash of the new commit differs, using only with `jq` and `git`. `fuiska` is also parallelized, massively speeding up
execution. On my laptop with 15 flake inputs, `nix flake update` takes 16 seconds, while `fuiska` takes 0.5 seconds.

`fuiska` aims to provide a more purposeful alternative to the Unify workflow. Rather than simply providing a list of
flake inputs that trigger a commit, `fuiska` instead just tells you the inputs that would be updated quickly, letting
you decide whether to commit. I personally *prefer* this workflow, but this depends on the individual.

## rbld

`rbld`, or "Rebuild But Less Dumb", is a fairly simple `nixos-rebuild` wrapper. Its main features are adding any newly
added files to the Git index via `git add -AN`, and piping output to
[nix-output-monitor](https://github.com/maralorn/nix-output-monitor). There isn't much unique functionality here -
you're free to use this, but you could also write your own script with very similar functionality.


## Installation (flakes)

To install any of these packages, add the repo to your flake inputs, as seen here:

```nix
  inputs = {
    menu = {
      url = "github:llakala/menu";

      # Not actually required, but good for preventing lockfile bloat.
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
```

Then, from any module where you can access your inputs, add whichever packages you'd like to install:

```nix
{ pkgs, inputs, ... }:

{
  environment.systemPackages = with inputs.menu.legacyPackages.${pkgs.system}; [
    rbld
    unify
    fuiska
  ];
}
```

## Installation (non-flakes)

First, fetch the repo in any way you like, whether it's through `fetchTarball`, `npins`, etc. Once it's fetched, you can
install packages from it like this:

```nix
{ pkgs, ... }:
let
  menu = import "${sources.menu}/packages/default.nix" { inherit pkgs; };
in {
  environment.systemPackages = with menu; [
    rbld
    unify
    fuiska
  ];
}
```

## Environment variables

rbld, unify, and fuiska provide flags for each run, such as specifying the directory to be used, the important inputs,
etc. However, to provide a custom default, environment variables can be used. These environment variables are:

- `RBLD_DIRECTORY` - respected by rbld, for setting the default directory holding your NixOS configuration. Default
  value: `/etc/nixos`.
- `UNIFY_DIRECTORY` - respected by unify and fuiska for setting a default directory for the repo's flake inputs to
  be updated. Default value: `/etc/nixos`.
- `UNIFY_TRACKED_INPUTS` - a space-separated list of the inputs that unify should check to see if a rebuild should be
  triggered. Default value: `nixpkgs menu`.
- `UNIFY_PRIMARY_BRANCHES` - a space-separated list of the branches that unify will automatically switch to if on a
  non-primary branch. Default value: `main master`.
- `UNIFY_COMMIT_MESSAGE` - the commit message that unify will use when automatically committing your `flake.lock`
  changes. Default value: `flake: update flake.lock`.
