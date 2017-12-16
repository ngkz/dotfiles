#!/usr/bin/env bats
# vim: ft=sh
# dotfiles
# Copyright (C) 2017  Kazutoshi Noguchi
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

work="$BATS_TMPDIR/work"
install="$BATS_TEST_DIRNAME/../install"

setup() {
    mkdir "$work"
}

teardown() {
    rm -rf "$work"
}

@test "pacman_install: no package specified" {
    cat <<'EOH' >"$work/test.df.sh"
pacman_install
EOH
    run "$install" "$work/test"
    [[ $status -eq 1 ]]
    [[ ${#lines[@]} -eq 2 ]]
    [[ ${lines[0]} = "no package specified" ]]
    [[ ${lines[1]} = "[ FAILED ] test: pacman_install " ]]
}

@test "pacman_install: install package and package group (dry run)" {
    cat <<'EOH' >"$work/test.df.sh"
# ensure that multilib-devel and tree are not installed
pacman -Qi $(pacman -Sgq multilib-devel) >/dev/null 2>&1 tree && exit 1
pacman_install multilib-devel tree
EOH
    run "$install" --dry-run "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "[CHANGED ] test: pacman_install multilib-devel tree" ]]
}

@test "pacman_install: install package and package group" {
    skip
    cat <<'EOH' >"$work/test.df.sh"
# ensure that multilib-devel and tree are not installed
pacman -Qi $(pacman -Sgq multilib-devel) tree >/dev/null 2>&1 && exit 1
pacman_install multilib-devel tree
pacman -Qi $(pacman -Sgq multilib-devel) tree >/dev/null 2>&1 || exit 1
pacman_install multilib-devel tree
EOH
    run "$install" "$work/test"
    [[ $status -eq 0 ]]
    [[ $output =~ "[CHANGED ] test: pacman_install multilib-devel tree" ]]
    [[ $output =~ "installing lib32-glibc..." ]]
    [[ $output =~ "installing lib32-gcc-libs..." ]]
    [[ $output =~ "installing tree..." ]]
    [[ $output =~ "[   OK   ] test: pacman_install multilib-devel tree" ]]
}

@test "pacman_update (dry run)" {
    rm -f /var/lib/pacman/sync/core.db
    echo "pacman_update" >"$work/test.df.sh"
    run "$install" --dry-run "$work/test"
    [[ $status -eq 1 ]]
    [[ ${#lines[@]} -eq 2 ]]
    [[ ${lines[0]} = "this action doesn't support --dry-run" ]]
    [[ ${lines[1]} = "[ FAILED ] test: pacman_update " ]]
    [[ ! -e /var/lib/pacman/sync/core.db ]]
}

@test "pacman_update" {
    rm -f /var/lib/pacman/sync/core.db
    echo "pacman_update" >"$work/test.df.sh"
    run "$install" "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "[CHANGED ] test: pacman_update " ]]
    [[ -e /var/lib/pacman/sync/core.db ]]

    run "$install" "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "[   OK   ] test: pacman_update " ]]
}
