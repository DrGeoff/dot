# Simple functions to make life easier to use the dot-* github repositories

# dot-* projects can have more than one config file.  This iterates over every config file.
dot-foreach-config()
{
    local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    local dotfiles=$(find $XDG_CONFIG_HOME/bash.d -type f \( ! -iwholename '*.git*' ! -name LICENSE \) )
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

# What dot-* are installed locally?
dot-installed()
{
    dot-foreach-project echo
}

# Create the equivalent .profile
dot-cat()
{
    dot-foreach-config cat
}

# What dot-* are available on github?
dot-available()
{
    curl -s https://api.github.com/users/DrGeoff/repos |jq '.[].name' |xargs |tr ' ' '\n' |grep ^dot
}

# dot-install/dot-clone:  Do a git clone of a github dot-* repo
dot-install()
{
    if [[ -z "$1" ]]; then
        echo Must specifiy a repository to ${FUNCNAME[0]}
        return
    fi

    local repo="$1"
    local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    pushd $XDG_CONFIG_HOME/bash.d >/dev/null
    git clone git@github.com:DrGeoff/${repo}
    popd >/dev/null
}
alias dot-clone=dot-install

# dot-rm: rm the repo from local disk
dot-rm()
{
    local repo="$1"
    local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    local local_repo=${XDG_CONFIG_HOME}/bash.d/${repo}
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
    local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    for project in ${versioned_projects}; do
        local local_repo=${XDG_CONFIG_HOME}/bash.d/${project}
        pushd ${local_repo} >/dev/null
        repostatus
        popd >/dev/null
    done

    local unversioned_projects=$(dot-unversioned | tr '\n' ' ') 
    for project in ${unversioned_projects}; do
        echo -e "$blue$project: $red unversioned"    
    done
}
