#!/usr/bin/env fish

set name $argv[1]
set full_contents $argv[2]

set data (echo $full_contents | jq -r ".pins.\"$name\"")
set type (echo $data | jq -r ".type")

switch $type
    case Git GitRelease
        if [ $type = Git ]
            set field ".branch"
        else
            set field ".version"
        end
        set ref (echo $data | jq -r $field)
        set repo_type (echo $data | jq -r ".repository.type")
        switch $repo_type
            case GitHub
                set owner (echo $data | jq -r ".repository.owner")
                set repo (echo $data | jq -r ".repository.repo")
                set url "https://github.com/$owner/$repo"
            case GitLab
                set url (echo $data | jq -r '.repository.server + .repository.repo_path + ".git"')
            case Git
                set url (echo $data | jq -r ".repository.url")
            case '*'
                echo "(Skipping $name of repo type $repo_type)"
                return 0
        end

        set old_hash (echo $data | jq -r ".revision")
        set new_hash (git ls-remote $url $ref | cut -f1)

        if [ "$new_hash" != "$old_hash" ]
            echo $name
        end
    case Channel
        # We do some regex magic on the current url in the lockfile to access:
        # 1. the key that this revision _would_ have in the s3 database
        # 2. the channel we're pointing to. s3 caps requests at 1000 objects, so
        # to stay under 1000, we only query for objects on the current channel.
        # We can't use the `.name` field, since it can sometimes look like
        # `nixos-unstable`, and we really need to search for the currently
        # unreleased version, a la `nixos-25.11`
        set pattern 'https:\/\/releases\.nixos\.org\/(((?:nixos\/)?[^\/]*\/[^-]*-\d+\.\d+)[^\/]*)'
        set groups (echo $data | jq -r ".url" | string match --regex $pattern -g)
        set old_key $groups[1]
        set channel $groups[2]

        # Query hydra's s3 bucket for all the objects on the current channel,
        # then access the most recent one. This is a horrible, dirty, no-good,
        # very bad hack. Please, help me find a way to kill this.
        set contents (curl -sS "https://nix-releases.s3.amazonaws.com/?delimiter=/&prefix=$channel")
        set new_key (echo $contents | xq -j | jq -r '.ListBucketResult.Contents | sort_by(.LastModified) | .[-1] | .Key')
        if [ "$old_key" != "$new_key" ]
            echo $name
        end
    case '*'
        echo "(Skipping $name of type $type)"
        return 0
end
