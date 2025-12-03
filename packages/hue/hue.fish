#! /usr/bin/env fish

# Hue-specific errors for ensuring we got a directory
if [ (count $argv) = 0 ]
    echo "Hue wasn't provided a directory as a positional parameter."
    exit 1
else if [ (count $argv) -gt 1 ]
    echo "Too many positional parameters were provided to Hue. Only one was expected."
    exit 1
end

set dir $argv[1]
set formatted_dir (string replace -r "^$HOME" "~" $dir) # Prettier for printing

if [ ! -d $dir ]
    echo "Directory `$formatted_dir` does not exist, and can't be used for rebuilding."
    exit 1
end

cd "$dir" # So we can test on the current directory

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1
    echo "Directory `$formatted_dir` isn't a git repo, and was expected to be one."
    exit 1
end

if [ ! -f flake.nix ]
    echo "Directory `$formatted_dir` doesn't contain a `flake.nix` file."
    exit 1
end
if [ ! -f flake.lock ]
    echo "Directory `$formatted_dir` doesn't contain a `flake.lock` file."
    exit 1
end

exit 0
