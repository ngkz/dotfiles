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

@test "patch: dry run" {
    echo "before" >"$work/file"
    cat <<'EOH' >"$work/file.patch"
--- /tmp/file.orig	2017-12-14 21:22:07.910315166 +0900
+++ /tmp/file	2017-12-14 21:22:12.893609837 +0900
@@ -1 +1 @@
-before
+after
EOH
    cat <<'EOH' >"$work/test.df.sh"
patch file file.patch
EOH
    run "$install" --dry-run "$work/test"
    (( status == 0 ))
    [[ $output = "[CHANGED ] test: patch file file.patch" ]]
    [[ $(<"$work/file") = "before" ]]
}

@test "patch: patch check fail" {
    echo "before" >"$work/file"
    cat <<'EOH' >"$work/test.df.sh"
patch file nonexistent.patch
EOH
    run "$install" --dry-run "$work/test"
    (( status == 1 ))
    [[ $output = "[ FAILED ] test: patch file nonexistent.patch" ]]
}

@test "patch: apply" {
    echo "before" >"$work/file"
    cat <<'EOH' >"$work/file.patch"
--- /tmp/file.orig	2017-12-14 21:22:07.910315166 +0900
+++ /tmp/file	2017-12-14 21:22:12.893609837 +0900
@@ -1 +1 @@
-before
+after
EOH
    cat <<'EOH' >"$work/test.df.sh"
patch file file.patch
EOH
    run "$install" "$work/test"
    (( status == 0 ))
    [[ $output = "[CHANGED ] test: patch file file.patch" ]]
    [[ $(<"$work/file") = "after" ]]

    run "$install" "$work/test"
    (( status == 0 ))
    [[ $output = "[   OK   ] test: patch file file.patch" ]]
}

@test "patch: apply fail" {
    echo "fail" >"$work/file"
    cat <<'EOH' >"$work/file.patch"
--- /tmp/file.orig	2017-12-14 21:22:07.910315166 +0900
+++ /tmp/file	2017-12-14 21:22:12.893609837 +0900
@@ -1 +1 @@
-before
+after
EOH
    cat <<'EOH' >"$work/test.df.sh"
patch file file.patch
EOH
    run "$install" "$work/test"
    (( status == 1 ))
    (( ${#lines[@]} == 2 ))
    [[ ${lines[0]} = "1 out of 1 hunk FAILED" ]]
    [[ ${lines[1]} = "[ FAILED ] test: patch file file.patch" ]]
}
