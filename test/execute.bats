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

@test "execute: no command specified" {
    echo "execute" >"$work/test.df.sh"
    run "$install" "$work/test"
    (( status == 1 ))
    (( ${#lines[@]} == 2 ))
    [[ ${lines[0]} = "no command specified" ]]
    [[ ${lines[1]} = "[ FAILED ] test: execute " ]]
}

@test "execute" {
    echo "execute touch $work/ok" >"$work/test.df.sh"
    run "$install" "$work/test"
    (( status == 0 ))
    [[ $output = "[   OK   ] test: execute touch $work/ok" ]]
    [[ -f "$work/ok" ]]
}

@test "execute: supress stdout" {
    echo "execute echo stdout" >"$work/test.df.sh"
    run "$install" "$work/test"
    (( status == 0 ))
    [[ $output = "[   OK   ] test: execute echo stdout" ]]
}

@test "execute: ignore shell function" {
    echo "execute _define" >"$work/test.df.sh"
    run "$install" "$work/test"
    (( status == 1 ))
    (( ${#lines[@]} == 2 ))
    [[ ${lines[0]} =~ "_define: command not found" ]]
    [[ ${lines[1]} = "[ FAILED ] test: execute _define" ]]
}

@test "execute (dry run)" {
    echo "execute touch $work/ok" >"$work/test.df.sh"
    run "$install" --dry-run "$work/test"
    (( status == 1 ))
    (( ${#lines[@]} == 2 ))
    [[ ${lines[0]} = "this action doesn't support --dry-run" ]]
    [[ ${lines[1]} = "[ FAILED ] test: execute touch $work/ok" ]]
    [[ ! -f "$work/ok" ]]
}
