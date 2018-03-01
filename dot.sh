# Simple functions to make life easier to use the dot-* github repositories

dot-foreach()
{
    local XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    local dotfiles=$(find $XDG_CONFIG_HOME/bash.d -type f -not -wholename '*.git*')
    for dotfile in $dotfiles; do
        eval "$1" $dotfile
    done
}

# What dot-* are installed locally?
dot-installed()
{
    dot-foreach echo
}

# Create the equivalent .profile
dot-cat()
{
    dot-foreach cat
}

# What dot-* are available on github?
dot-available()
{
    curl -s https://api.github.com/users/DrGeoff/repos |jq '.[].name' |xargs |tr ' ' '\n' |grep ^dot
}

# dot-install/dot-clone:  Do a git clone of a github dot-* repo
dot-install()
{
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


