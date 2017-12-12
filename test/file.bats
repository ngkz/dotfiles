#!/usr/bin/env bats
# vim: ft=sh

work="$BATS_TMPDIR/file"
install="$BATS_TEST_DIRNAME/../install"

setup() {
    mkdir "$work"
}

teardown() {
    rm -rf "$work"
}

@test "file action fails if invalid option is passed" {
    echo "file --invalid-option src dest" >"$work/test.df.sh"
    run "$install" "$work/test"
    [[ $status -eq 1 ]]
    [[ $output =~ "file: unrecognized option '--invalid-option'" ]]
    [[ $output =~ "[ FAILED ]" ]]
}

@test "file action prints an error if the wrong number of arguments are passed" {
    echo "file src" >"$work/test.df.sh"
    run "$install" "$work/test"
    [[ $status -eq 1 ]]
    [[ ${lines[0]} =~ "[ FAILED ]" ]]
    [[ ${lines[1]} = "Wrong number of arguments" ]]
}

@test "file --owner (skip)" {
    touch "$work/src" "$work/dest"
    cat <<'EOH' >"$work/test.df.sh"
_changed=1
file --owner=nobody src dest
echo -n "is-changed is "; is-changed && echo true || echo false
EOH

    run "$install" "$work/test" </dev/null
    [[ $status -eq 0 ]]
    [[ ${lines[1]} = 'Different owner (current: root, desired: nobody)' ]]
    [[ ${lines[2]} = 'Fix inconsistency? [y/N] ' ]]
    [[ ${lines[3]} =~ '[SKIPPED ]' ]]
    [[ ${lines[4]} = 'is-changed is false' ]]
    [[ $(stat --format="%U" "$work/dest") = 'root' ]]
}

@test "file --owner (changed)" {
    touch "$work/src" "$work/dest"
    cat <<'EOH' >"$work/test.df.sh"
_changed=0
file --owner=nobody src dest
echo -n "is-changed is "; is-changed && echo true || echo false
EOH

    run "$install" -y "$work/test" </dev/null
    [[ $status -eq 0 ]]
    [[ ${lines[1]} = 'Different owner (current: root, desired: nobody)' ]]
    [[ ${lines[2]} = 'Fix inconsistency? [y/N] Y' ]]
    [[ ${lines[3]} =~ '[CHANGED ]' ]]
    [[ ${lines[4]} = 'is-changed is true' ]]
    [[ $(stat --format="%U" "$work/dest") = 'nobody' ]]
}

@test "file --owner (ok)" {
    touch "$work/src" "$work/dest"
    chown nobody "$work/dest"
    cat <<'EOH' >"$work/test.df.sh"
_changed=1
file --owner=nobody src dest
echo -n "is-changed is "; is-changed && echo true || echo false
EOH

    #verify
    run "$install" "$work/test" </dev/null
    [[ $status -eq 0 ]]
    [[ ${lines[0]} =~ '[   OK   ]' ]]
    [[ ${lines[1]} = 'is-changed is false' ]]
}
