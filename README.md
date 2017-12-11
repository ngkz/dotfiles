# ngkz/dotfiles
my dotfiles and configuration managent tool (WIP)

## how to use
(TODO)

```sh
./install
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
