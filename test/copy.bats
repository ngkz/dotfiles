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
    mkdir "$work/src"
    touch "$work/src/regular"
    ln -s regular "$work/src/symlink"
    find "$work/src" -exec touch --no-dereference --date="2000/01/01 12:34" "{}" ";"
}

teardown() {
    rm -rf "$work"
}

@test "copy: dry run" {
    cat <<'EOH' >"$work/test.df.sh"
copy src/ dest
EOH
    run "$install" --dry-run "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "[CHANGED ] test: copy src/ dest" ]]
    [[ ! -e "$work/dest" ]]
}

@test "copy" {
    cat <<'EOH' >"$work/test.df.sh"
copy src/ dest
EOH
    run "$install" "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "[CHANGED ] test: copy src/ dest" ]]

    run ls -l "$work/src"
    [[ $status -eq 0 ]]
    src_ls=$output
    run ls -l "$work/dest"
    [[ $status -eq 0 ]]
    dest_ls=$output
    [[ $src_ls = "$dest_ls" ]]

    run "$install" "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "[   OK   ] test: copy src/ dest" ]]
}

@test "copy: --chown" {
    cat <<'EOH' >"$work/test.df.sh"
copy --chown nobody:nobody src/ dest
EOH
    run "$install" "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "[CHANGED ] test: copy --chown nobody:nobody src/ dest" ]]

    run ls -l "$work/dest"
    [[ $status -eq 0 ]]
    [[ ${#lines[@]} -eq 3 ]]
    [[ ${lines[0]} = "total 0" ]]
    [[ ${lines[1]} = "-rw-r--r-- 1 nobody nobody 0 Jan  1  2000 regular" ]]
    [[ ${lines[2]} = "lrwxrwxrwx 1 nobody nobody 7 Jan  1  2000 symlink -> regular" ]]
}

@test "copy: --chmod" {
    cat <<'EOH' >"$work/test.df.sh"
copy --chmod 0432 src/ dest
EOH
    run "$install" "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "[CHANGED ] test: copy --chmod 0432 src/ dest" ]]

    run ls -l "$work/dest"
    [[ $status -eq 0 ]]
    [[ ${#lines[@]} -eq 3 ]]
    [[ ${lines[0]} = "total 0" ]]
    [[ ${lines[1]} = "-r---wx-w- 1 root root 0 Jan  1  2000 regular" ]]
    [[ ${lines[2]} = "lrwxrwxrwx 1 root root 7 Jan  1  2000 symlink -> regular" ]]
}

@test "copy: --delete" {
    cp -ar "$work/src" "$work/dest"
    touch "$work/dest/destonly"
    cat <<'EOH' >"$work/test.df.sh"
copy --delete src/ dest
EOH
    run "$install" "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "[CHANGED ] test: copy --delete src/ dest" ]]
    [[ ! -e "$work/dest/destonly" ]]
}
