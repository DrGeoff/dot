# Simple functions to make life easier to use the dot-* github repositories

# dot-* projects can have more than one config file.  This iterates over every config file.
dot-foreach-config()
{
    local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    local dotfiles=$(find $XDG_CONFIG_HOME/bash.d -type f \( ! -iwholename '*.git*' ! -name 'LICEN*' ! -name README  ! -name '*spec' \) )
    for dotfile in $dotfiles; do
        eval "$1" $dotfile
    done
}

# A dot-* project may or may not be version controlled.  This iterates over every project name.
dot-foreach-project()
{
    local versioned_projects=$(dot-versioned | tr '\n' ' ')
    local unversioned_projects=$(dot-unversioned | tr '\n' ' ') 
    for project in ${versioned_projects} ${unversioned_projects}; do
        eval "$1" ${project}
    done
}

# Iterate over only the version controlled projects
dot-foreach-versioned-project()
{
    local versioned_projects=$(dot-versioned | tr '\n' ' ')
    for project in ${versioned_projects}; do
        eval "$1" ${project}
    done
}

# What dot-* are installed locally?
dot-installed()
{
    dot-foreach-project echo
}

# Echo the config name before cat
echo-cat()
{
    echo "#"
    echo "# $1"
    echo "#"
    eval cat "$1"
    echo
}

# What is the local pathname for the repositories cloned from github
localname()
{
    local repo="$1"
    local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    echo ${XDG_CONFIG_HOME}/bash.d/${repo}
}

# Update a given single repository
do-git-pull()
{
    # $1 is expected to be the name of a local git repository
    local localrepo=$(localname "$1")
    pushd ${localrepo}
    git pull --rebase
    popd >/dev/null
}

# Update all projects
dot-update()
{
    dot-foreach-versioned-project do-git-pull
}

# Create the equivalent .profile
dot-cat()
{
    dot-foreach-config echo-cat
}

# Figure out the github user name
dot-github-user()
{
    # If $1 exists then assume $1 is the github user name, but if no $1 is passed in then try to find their name in .gitconfig
    local gitconfig_name=""
    if [[ -s ${HOME}/.gitconfig ]]; then
        local gitconfig_nameline=$(grep name ${HOME}/.gitconfig |head -1)
        gitconfig_name=${gitconfig_nameline#*= }
    fi
    github_user=${1:-$gitconfig_name}

    if [[ -z ${github_user} ]]; then
        echo >&2 Could not determine the github user.  Either pass a valid github user name or put a "name=" into your .gitconfig.
        exit 1
    fi

    echo ${github_user}
}

# What dot-* are available on github?
dot-available()
{
    local github_user=$(dot-github-user "$1")
    local available=$(curl -s https://api.github.com/users/${github_user}/repos)
    local names=$(jq '.[] | {name,html_url}' <<<${available})

    # If there are repositories named dot-* then assume that they are the only ones we want to see
    if [[ $(jq 'select(.name | startswith("dot"))' <<< ${names} |wc -l) -gt 0 ]]; then
        jq 'select(.name | startswith("dot"))' <<< ${names}
    else
        jq '.' <<< ${names}
    fi
}

# dot-install/dot-clone:  Do a git clone of a github dot-* repo
dot-install()
{
    # $1 must be either a full clonable repository like
    # https://github.com/wolfwoolford/dish.git
    # or a repository under their github username

    if [[ -z "$1" ]]; then
        echo Must specifiy a repository to ${FUNCNAME[0]}
        return
    fi

    # If the reponame contains github, assume that it is a full github name
    # otherwise tack on all the other bits and bobs.
    local repo="$1"
    if [[ ! $repo =~ .*github.* ]]; then
        local github_user=$(dot-github-user)
        repo=git@github.com:${github_user}/${repo}
    fi

    # 
    local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    mkdir -p $XDG_CONFIG_HOME/bash.d
    pushd $XDG_CONFIG_HOME/bash.d >/dev/null
    git clone ${repo} 
    popd >/dev/null
}
alias dot-clone=dot-install

# dot-rm: rm the repo from local disk
dot-rm()
{
    local local_repo=$(localname "$1")
    if [[ -d ${local_repo} ]]; then            
        rm -rf ${local_repo}
    fi
}


# dot-versioned: Which of the configs are locally in version control?
dot-versioned()
{
    local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    local bd=${XDG_CONFIG_HOME}/bash.d
    gits=$(find $bd -name ".git" -type d)
    for gt in ${gits}; do
        basename $(readlink -f ${gt}/..)
    done
}

# dot-unversioned: Which of the configs are not in version control?
dot-unversioned()
{
    local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    local bd=${XDG_CONFIG_HOME}/bash.d
    cfgs=$(find $bd -maxdepth 1 -type f)
    for cfg in ${cfgs}; do
        basename ${cfg}
    done
}

# dot-status: What is the git status of the versioned configs 
dot-status()
{
    local versioned_projects=$(dot-versioned | tr '\n' ' ')
    for project in ${versioned_projects}; do
        local local_repo=$(localname ${project})
        pushd ${local_repo} >/dev/null
        repostatus
        popd >/dev/null
    done

    local unversioned_projects=$(dot-unversioned | tr '\n' ' ') 
    for project in ${unversioned_projects}; do
        echo -e "$blue$project: $red unversioned"    
    done
}

