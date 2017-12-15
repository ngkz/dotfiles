# ngkz/dotfiles
my dotfiles and configuration managent tool (WIP)

## dependencies
```sh
pacman -S util-linux #getopt command
pacman -S which      #which command
pacman -S patch      #patch command
pacman -S rsync      #rsync command
```

## how to use
(TODO)

```sh
$ ./install --help
Usage: ./install [OPTIONS]... [SCRIPT]...
Options:
  -h, --help            display this help and exit
  -y, --yes             apply changes without your confirmation
  -v, --verbose         show the action that made no change
```

## how to lint
```sh
shellcheck install lib/* test/*.sh
```

## how to test
Some tests modify the system. Don't run tests outside of docker!

```sh
docker pull archlinux/base
docker build -t dotfiles-test .
docker run -t --rm -v "$(pwd):/dotfiles:ro" dotfiles-test
```
