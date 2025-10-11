#! /usr/bin/env fish

set directory (revive $IMANPU_DIRECTORY "/etc/nixos/npins")

set options (fish_opt --required --short d --long directory)
argparse $options -- $argv
if set -q _flag_directory
    set directory $_flag_directory
end

if [ ! -d $directory ]
    echo "Directory `$directory` doesn't exist."
    exit 1
else if [ ! -f "$directory/sources.json" ]
    echo "Directory `$directory` doesn't contain a `sources.json` file."
    exit 1
end

set contents "$(cat "$directory/sources.json")"

set npins_version (echo $contents | jq -r ".version")
if [ $npins_version != 6 ]
    echo "Unsupported version $npins_version"
    return
end

set inputs (echo $contents | jq -r ".pins | keys[]")
echo "Sources that need updating:"
for name in $inputs
    qwesu $name $contents &
end

wait
