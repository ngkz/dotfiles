# ngkz/dotfiles
my dotfiles and configuration managent tool (WIP)

## dependencies
```sh
#minimal dependencies
pacman -S util-linux which #getopt, which
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
./lint
```

## how to test
Some tests modify the system. Don't run tests outside of docker!

```sh
docker pull archlinux/base
docker build -t dotfiles-test .
docker run -t --rm -v "$(pwd):/dotfiles:ro" dotfiles-test
```

# checklist
## when commit
[ ] test
[ ] lint
[ ] add a license header

## when writing a action
[ ] handle an error correctly
[ ] handle --dry-run correctly
[ ] handle changed flag correctly
