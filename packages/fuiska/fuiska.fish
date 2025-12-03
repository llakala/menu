#! /usr/bin/env fish

# Override value with `-d` / `--directory`
set options (fish_opt --required-val --short d --long directory)
argparse $options -- $argv

set -e directory
# Use directory from flag if used
if set -q _flag_directory
    set directory (realpath -s $_flag_directory)
    hue $directory || exit
else if set -q UNIFY_DIRECTORY
    # If there's a default, use current dir if it passes `hue`, or fall back on default
    set directory $PWD
    if not hue $directory > /dev/null
        echo "Current dir invalid, using default directory"
        set directory (realpath -s $UNIFY_DIRECTORY)
        hue $directory || exit
    end
else
    # No default, no flag - use current dir
    set directory $PWD
    hue $directory || exit
end

# We do the check here, so that if your default dir is the current one, or you
# pass `-d .`, you stil lget the right result
if [ $directory = $PWD ]
    echo "Inputs that need updating for current directory:"
else
    set formatted_dir (string replace -r "^$HOME" "~" $directory)
    echo "Inputs that need updating for $formatted_dir:"
end

# We use "$()" to save as a multiline string
set full_contents "$(cat $directory/flake.lock)"
set names (echo $full_contents | jq -r ".nodes.root.inputs | keys[]")

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
