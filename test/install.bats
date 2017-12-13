#!/usr/bin/env bats
# vim: ft=sh

work="$BATS_TMPDIR/work"
install="$BATS_TEST_DIRNAME/../install"

setup() {
    mkdir "$work"
}

teardown() {
    rm -rf "$work"
}

@test "install --dry-run" {
    echo 'is_dry_run && echo yes || echo no' >"$work/test.df.sh"
    run "$install" --dry-run "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "yes" ]]

    run "$install" "$work/test"
    [[ $status -eq 0 ]]
    [[ $output = "no" ]]
}

@test "_define: check number of arguments" {
    cat <<'EOH' >"$work/test.df.sh"
_define action impl extra
EOH
    run "$install" "$work/test"
    [[ $status -eq 1 ]]
    [[ $output = 'Wrong number of arguments' ]]

    cat <<'EOH' >"$work/test.df.sh"
_define action impl
EOH
    run "$install" "$work/test"
    [[ $status -eq 0 ]]
}

@test "_define: define action" {
    cat <<'EOH' >"$work/test.df.sh"
impl_ok() {
    i=1
    while (( $# > 0 )); do
        echo "\$$i => $1"
        shift
        ((i++))
    done
    return 0
}

_define action_ok impl_ok

impl_changed() {
    _flag_changed
    return 0
}

_define action_changed impl_changed

impl_failed() {
    return 1
}

_define action_failed impl_failed

action_ok "arg1" "ar  g2"
action_changed "arg1" "ar  g2"
is_changed && echo "changed flag is set"
action_ok
is_changed || echo "changed flag is reset"
action_failed "arg1" "ar  g2"
echo "this won't get executed"
EOH
    run "$install" "$work/test"
    [[ $status -eq 1 ]]
    [[ ${#lines[@]} -eq 8 ]]
    [[ ${lines[0]} = '$1 => arg1' ]]
    [[ ${lines[1]} = '$2 => ar  g2' ]]
    [[ ${lines[2]} = '[   OK   ] test: action_ok arg1 ar  g2' ]]
    [[ ${lines[3]} = '[CHANGED ] test: action_changed arg1 ar  g2' ]]
    [[ ${lines[4]} = 'changed flag is set' ]]
    [[ ${lines[5]} = '[   OK   ] test: action_ok ' ]]
    [[ ${lines[6]} = 'changed flag is reset' ]]
    [[ ${lines[7]} = '[ FAILED ] test: action_failed arg1 ar  g2' ]]
}
