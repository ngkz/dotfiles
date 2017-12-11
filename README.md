# ngkz/dotfiles
my dotfiles and configuration managent tool (WIP)

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
shellcheck install lib/*
```

## how to test
```sh
docker pull archlinux/base
docker build -t dotfiles-test .
docker run -v $(pwd):/dotfiles:ro --rm dotfiles-test
```
