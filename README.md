# Dev Setup

## About

This is a script to automate some of the things I do when I set up a new CentOS 7 dev server.

It will do the following:
- Installs with root:
  - Updates
  - epel-release
  - Basic apps
    - git
    - vim
    - wget
    - tmux
    - htop
    - nano
    - nginx
    - mlocate (updatedb)
    - python-devl
    - zlib-devel
    - bzip2
    - bzip2-devel
    - realine-devel
    - sqlite
    - sqlite-devel
    - openssl-devel
    - httpd-tools
  - Development Tools
  - [NodeJS](https://nodejs.org/en/) (optional
  - [Meteor](https://www.meteor.com/) (optional)
  - [Docker](https://www.docker.com/) (optional)

- Creates a dev user and installs:
  - [pyenv](https://github.com/yyuu/pyenv)
  - [Cloud9](https://github.com/c9/core) (standalone)
    - Configure nginx for c9
    - Create SSL certs
    - Create authentication using htpasswd

*Note: Right now Cloud9 is reverted back to version [3.1.1407](https://github.com/c9/core/commit/c471ab0e4c7cb983e1e4c40675b3fd63916c9394) due to a bug in the current release.*


## Install

To install this just clone the repo

    git clone https://github.com/the4tress/dev-setup.git
    
## Execute

To install the applications run setup.sh

    cd dev-setup
    ./setup.sh
