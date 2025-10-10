#! /usr/bin/env fish

# Equivalent of "${UNIFY_DIRECTORY:/etc/nixos}" in bash
set directory (revive $UNIFY_DIRECTORY "/etc/nixos")

set -l option1 (fish_opt --required --short d --long directory)

set options $option1
argparse $options -- $argv

# Override value with `-d` / `--directory`
if set -q _flag_directory
    set directory $_flag_directory
end

# Fail early here if hue says bad, since `set -e` doesn't exist
hue $directory || exit
cd $directory

# We use "$()" to save as a multiline string
set full_contents "$(cat flake.lock)"
set names (echo $full_contents | jq -r ".nodes.root.inputs | keys[]")

echo "Inputs that need updating:"

# We parallelize checking the input via `&`
for name in $names
    # If the user has multiple inputs of a duplicate name, the internal location
    # of the input won't be `nixpkgs` as the user expects - it might be
    # `nixpkgs_2`. We send the name and location separately, so we can read from
    # the relevant part of the file, but print the name the user expects
    set location (echo $full_contents | jq -r --arg name $name '.nodes.root.inputs[$name]')
    fight $name $location $full_contents &
end

wait
