FROM archlinux/base
COPY 00_pacman/mirrorlist /etc/pacman.d/mirrorlist
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm bash-bats
CMD ["bats", "/dotfiles/test"]
