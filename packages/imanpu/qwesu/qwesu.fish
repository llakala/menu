#!/usr/bin/env fish

set name $argv[1]
set full_contents $argv[2]

set data (echo $full_contents | jq -r ".pins.\"$name\"")
set type (echo $data | jq -r ".type")

set frozen (echo $data | jq -r "if .frozen then 0 else 1 end")
if [ $frozen = 0 ]
    return 0
end

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
        set channel (echo $data | jq -r ".name")
        set old_rev (echo $data | jq -r ".url" | string match --regex --groups-only "([^.]*)\/nixexprs.tar.xz")

        set api_response (curl -sS https://prometheus.nixos.org/api/v1/query -d "query=channel_revision{channel='$channel'}")
        set new_rev (echo $api_response | jq -r ".data.result[0].metric.revision" | string sub --length 12)

        if [ "$old_rev" != "$new_rev" ]
            echo $name
        end
    case '*'
        echo "(Skipping $name of type $type)"
        return 0
end
