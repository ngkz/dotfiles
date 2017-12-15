FROM archlinux/base
COPY 00_pacman/mirrorlist /etc/pacman.d/mirrorlist
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm bash-bats util-linux which patch rsync
CMD ["bats", "/dotfiles/test"]
