#! /usr/bin/env fish
# We store this in a separate script from Fuiska, since Fish can't parallelize functions

set name $argv[1]
set location $argv[2]
set full_contents $argv[3]

# Sometimes a flake.lock has duplicate entries of an input, and they'll be
# stored at `nixpkgs_2`. We access the data at the correct location, while
# printing the name the user knows the input by
set data (echo $full_contents | jq -r --arg location $location '.nodes[$location]')

if [ -z "$data" ]
    echo "No data found for input: $name"
    exit 1
end

# The input will never update if it points to a specific commit hash
set evergreen (echo $data | jq -r "if .original.rev then 0 else 1 end")

if [ $evergreen = 0 ]
    exit 0
end

set oldHash (echo $data | jq -r ".locked.rev")
set ref (echo $data | jq -r 'if .original.ref then .original.ref else "" end') # Either a branch or a tag

set host (echo $data | jq -r ".original.type")

switch $host

    case github gitlab
        # We make URL point to generic repo, and pass ref in as an argument
        set url (echo $data | jq -r '"https://" + .original.type + ".com/" + .locked.owner + "/" + .original.repo + ".git"')
    case git
        set url (echo $data | jq -r '.original.url')
        # Exit early on git+ssh inputs, as we don't have any logic for parsing
        # them right now
        if echo $url | rg -q "^ssh://"
            echo "WARNING: skipping input $name of type git+ssh, as there's no logic for parsing it right now"
            exit 0
        else
        end

    case tarball
        # Flakes provide the direct tarball URL, but it's pointing to a tarball,
        # which we can't query without downloading.
        # Instead, we check if the URL looks something like:
        # `web.site/$1/$2/archive/$3.tar.gz'
        # If so, we can try ls-remote on it
        set tarballUrl (echo $data | jq -r '.original.url')
        set regexPattern '(https?:\/(?:\/[^\/]+){3})\/(?:archive|releases\/download)\/(?:refs\/tags\/)?([^\/]+)(?:\/[^\/]+)?(?:\.tar\.gz|\.zip|\.tar\.xz)'

        set -l both (echo $tarballUrl | string match $regexPattern --regex --groups-only)

        if [ -z "$both" ] # URL doesn't match
            echo "WARNING: skipping input $name of type tarball, as it can't be automatically reconstructed into a repo link"
            exit 0
        end

        set url $both[1]
        set ref $both[2]

        # Check if the ref is a specific commit, which can't be checked by ls-remote
        # Commits should be evergeen, skip it and move on
        if [ (echo -n $ref | wc -c) = 40 ]
            exit 0
        end

    case '*'
        echo "WARNING: skipping input $name of type $host, as it's currently unparseable"
        exit 0

end

# If we don't point to a specific tag or branch
# Sometimes the ref will literally be "HEAD". If we don't catch it here,
# this if statement wouldn't trigger, and we would add `--branches` and
# `--tags`, which would break the fetch. See https://github.com/llakala/menu/pull/39
# where this was fixed
if [ -z "$ref" ]; or [ "$ref" = HEAD ]
    set newHash (git ls-remote $url "HEAD" | cut -f1)

else
    # Nix doesn't unpeel tarball refs, so we don't either to compare with the revision it stores
    if [ $host != tarball ]
        set ref $ref $ref^{}
    end

    # Check both branches AND tags. We check for both the normal ref and the
    # unpeeled ref. Unpeeling the ref will do nothing for branches, but it lets
    # annotated tags work properly.
    set output (git ls-remote --branches --tags $url $ref | string collect)
    set ref_hashes (echo $output | cut -f1)
    set ref_names (echo $output | cut -f2)

    # If the input used an annotated tag, we'll get a list of length two - one
    # for the lightweight, and one for the annotated one.. Lightweight tags and
    # branches should be in a list of length 1. However, sometimes we get an
    # extra match here, like `refs/branches/master` and
    # `refs/branches/update/master`. To work around this, we only use the last
    # element in the list if it ends with `^{}`. If it doesn't, we use the first
    # element. This is a bit of a hack - make an issue if it gives bad results
    # for you!
    if string match -q --regex "\^{}\$" $ref_names[-1]
        set newHash $ref_hashes[-1]
    else
        set newHash $ref_hashes[1]
    end
end
if [ -z "$newHash" ]
    echo "ERROR: $name failed to fetch a commit hash with url `$url` and ref `$ref`"
    exit 1
end

if [ $oldHash != $newHash ]
    echo $name
end
