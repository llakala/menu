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

# Went through the commit history, and I don't currently rely on anything added
# since version 3. I could be even more permissive, but there's only three repos
# on github that use a version < 3, so this should be fine
set npins_version (echo $contents | jq -r ".version")
set min_version 3
set max_version 7
if [ $npins_version -lt $min_version ]
    echo "Your npins lockfile is from version $npins_version"
    echo "imanpu only supports versions $min_version-$max_version"
    echo "Please update your lockfile with `npins upgrade`"
    return
else if [ $npins_version -gt $max_version ]
    echo "Your npins lockfile is from version $npins_version"
    echo "imanpu only supports versions $min_version-$max_version"
    echo "Please downgrade your lockfile, or make an issue at https://github.com/llakala/menu to support the new version"
    return

end

set inputs (echo $contents | jq -r ".pins | keys[]")
echo "Sources that need updating:"
for name in $inputs
    qwesu $name $contents &
end

wait
