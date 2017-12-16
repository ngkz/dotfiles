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
    mkdir "$work/mock"
    #FIXME horrible code
    cat <<EOH >"$work/mock/systemctl"
#!/bin/bash
echo "\$*" >> "$work/log"
case "\$*" in
    "is-enabled test")
        echo disabled
        exit 1
        ;;
    "enable test")
        echo Created symlink ...
        exit 0
        ;;
    "is-enabled nonexistent")
        echo "Failed to get unit file state for nonexistent.service: No such file or directory" >&2
        exit 1
        ;;
    "is-enabled nonexistent")
        echo "Failed to get unit file state for nonexistent.service: No such file or directory" >&2
        exit 1
        ;;
    "enable nonexistent")
        echo "Failed to enable unit: Unit file nonexistent.service does not exist." >&2
        exit 1
        ;;
esac
EOH
    chmod +x "$work/mock/systemctl"
}

teardown() {
    rm -rf "$work"
}

@test "systemctl: enable (dry run)" {
    echo "systemctl enable test" >"$work/test.df.sh"
    PATH="$work/mock:$PATH" run "$install" --dry-run "$work/test"
    (( status == 0 ))
    [[ $output = "[CHANGED ] test: systemctl enable test" ]]
    [[ $(<"$work/log") = "is-enabled test" ]]
}

@test "systemctl: enable" {
    echo "systemctl enable test" >"$work/test.df.sh"
    PATH="$work/mock:$PATH" run "$install" "$work/test"
    (( status == 0 ))
    [[ $output = "[CHANGED ] test: systemctl enable test" ]]
    [[ $(<"$work/log") = "is-enabled test
enable test" ]]
}

@test "systemctl: invalid command" {
    echo "systemctl nonexistent test" >"$work/test.df.sh"
    PATH="$work/mock:$PATH" run "$install" "$work/test"
    (( status == 1 ))
    (( ${#lines[@]} == 2 ))
    [[ ${lines[0]} = "invalid command" ]]
    [[ ${lines[1]} = "[ FAILED ] test: systemctl nonexistent test" ]]
}

@test "systemctl: invalid name" {
    echo "systemctl enable nonexistent" >"$work/test.df.sh"
    PATH="$work/mock:$PATH" run "$install" "$work/test"
    (( status == 1 ))
    (( ${#lines[@]} == 2 ))
    [[ ${lines[0]} = "Failed to enable unit: Unit file nonexistent.service does not exist." ]]
    [[ ${lines[1]} = "[ FAILED ] test: systemctl enable nonexistent" ]]
    [[ $(<"$work/log") = "is-enabled nonexistent
enable nonexistent" ]]
}
