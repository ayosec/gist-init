# gist-init

Creates a new [GitHub gist](https://gist.github.com), and pushes the repository in the current directory to it.

Gists are private by default.

## Installation

    # wget https://github.com/ayosec/gist-init/raw/master/gist-init.rb -O /usr/local/bin/gist-init
    # chmod +x /usr/local/bin/gist-init

## Usage

    $ gist-init --help
    Usage: gist-init [options]
        -p, --public                     Create a public gist
        -u, --user [USER]                GitHub user name
            --password [PASSWORD]        GitHub password
        -d, --description [DESCRIPTION]  Gist description

## Example

    $ vi foo.md
    $ git init
    $ git add .
    $ git commit --allow-empty-message -a
    $ gist-init
