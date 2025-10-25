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
    case '*'
        echo "(Skipping $name of type $type)"
        return 0
end
