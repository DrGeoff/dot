===
dot
===

-------------------------------------
Tools to manage .bashrc configuration
-------------------------------------

DESCRIPTION
===========
Over time the .bashrc file accumulates snippets of code that are unrelated to
other snippets of code. It would be cleaner if unrelated code snippets are 
kept separately.  dot provides tools to help install small snippets of 
bash configuration which are kept in their own git repositories.

The snippets are kept under the XDG_CONFIG_HOME/bash.d/ in their own git
repositories.  For example, ::

    .config/bash.d/
    ├── dish
    │   ├── dishrc
    │   ├── dish.spec
    │   ├── LICENCE.txt
    │   └── README
    ├── dot
    │   ├── colours
    │   ├── dot.sh
    │   ├── git-functions
    │   ├── LICENSE
    │   └── README.rst
    ├── dot-jumpmarks
    │   └── jumpmarks

.bashrc then is reduced to programatically gathering together all the snippets.

dot provides a suite of commands to install, monitor and update the snippets.

* dot-available: What dot-* are available on github?
  Example: ``dot-available DrGeoff``, ``dot-available wolfwoolford``
  If your github user is in .gitconfig then ``dot-available`` will 
  show your own github repositories.  If you prefix your bashrc repositories with
  ``dot-`` then dot-available will restrict itself to only showing ``dot-*``
  repositories.
* dot-install/dot-clone:  Do a git clone of a github dot-* repo
  Example: ``dot-install https://github.com/DrGeoff/dot-jumpmarks``
* dot-rm: Remove the repo from local disk
* dot-versioned: Which of the configs are locally in version control?
* dot-unversioned: Which of the configs are not in version control?
* dot-status: What is the git status of the versioned configs 
* dot-update: Update all projects

DEPENDENCIES
============
bash jq curl

INSTALLATION
============
You can either git clone directly to the location that the dot-* repositories
are expected to live in or you can do a bootstrap installation by installing to
a temporary location and then use dot to install itself.

DIRECT INSTALLATION
===================
dot can manage itself if it is installed to the expected location.  The 
following will create the expected location and install dot from github 
directly to the expected location. ::

    XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    mkdir -p ${XDG_CONFIG_HOME}/bash.d
    cd !$
    git clone https://github.com/DrGeoff/dot.git   # Clone to the final location

BOOTSTRAP INSTALLATION 
======================
The idea is to use a temporary copy of dot.sh to install dot to the expected location. ::

    git clone https://github.com/DrGeoff/dot.git   # Clone to a temporary location
    source dot/dot.sh                              # Get the dot commands into the current bash environment
    dot-install https://github.com/DrGeoff/dot.git # Use dot to install itself 
    rm -rf dot                                     # Cleanup the temporary installation

MODIFY .bashrc
==============
The following three lines need to be inserted into your .bashrc ::

    XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
    source $XDG_CONFIG_HOME/bash.d/dot/dot.sh
    dot-foreach-config source

Log out and log in for all the dot goodness. 
