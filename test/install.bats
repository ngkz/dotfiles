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
    (( status == 0 ))
    [[ $output = "yes" ]]

    run "$install" "$work/test"
    (( status == 0 ))
    [[ $output = "no" ]]
}

@test "_define: check number of arguments" {
    cat <<'EOH' >"$work/test.df.sh"
_define action impl extra
EOH
    run "$install" "$work/test"
    (( status == 1 ))
    [[ $output = 'Wrong number of arguments' ]]

    cat <<'EOH' >"$work/test.df.sh"
_define action impl
EOH
    run "$install" "$work/test"
    (( status == 0 ))
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
    (( status == 1 ))
    (( ${#lines[@]} == 8 ))
    [[ ${lines[0]} = '$1 => arg1' ]]
    [[ ${lines[1]} = '$2 => ar  g2' ]]
    [[ ${lines[2]} = '[   OK   ] test: action_ok arg1 ar  g2' ]]
    [[ ${lines[3]} = '[CHANGED ] test: action_changed arg1 ar  g2' ]]
    [[ ${lines[4]} = 'changed flag is set' ]]
    [[ ${lines[5]} = '[   OK   ] test: action_ok ' ]]
    [[ ${lines[6]} = 'changed flag is reset' ]]
    [[ ${lines[7]} = '[ FAILED ] test: action_failed arg1 ar  g2' ]]
}

@test "_define: quote action and impl correctly" {
    cat <<'EOH' >"$work/test.df.sh"
impl() {
    echo failed
    return 0
}

_define 'A=B; action' impl
action
EOH
    run "$install" "$work/test"
    (( status == 1 ))
    [[ $output =~ 'syntax error near unexpected token `(' ]]

    cat <<'EOH' >"$work/test.df.sh"
impl() {
    echo failed
    return 0
}

_define action '$(echo -n impl)'
action
EOH
    run "$install" "$work/test"
    (( status == 1 ))
    [[ $output =~ '$(echo -n impl): command not found' ]]
}

@test "_parse_action_args: parse non option arguments" {
    cat <<EOH >"$work/test.df.sh"
. "$BATS_TEST_DIRNAME/parse_action_args_helper.sh"

pollute_args_and_varargs
_parse_action_args arg1 arg2 -- test1 test2 || exit 1
dump_args_and_varargs

pollute_args_and_varargs
_parse_action_args arg1 -- test3 || exit 1
dump_args_and_varargs

pollute_args_and_varargs
_parse_action_args arg1 arg2 -- toofewargs && exit 1
dump_args_and_varargs

pollute_args_and_varargs
_parse_action_args arg1 && exit 1
dump_args_and_varargs
EOH
    run "$install" "$work/test"
    (( status == 0 ))
    (( ${#lines[@]} == 5 ))
    [[ ${lines[0]} = '_args[arg1] => test1' ]]
    [[ ${lines[1]} = '_args[arg2] => test2' ]]
    [[ ${lines[2]} = '_args[arg1] => test3' ]]
    [[ ${lines[3]} = 'Wrong number of arguments' ]]
    [[ ${lines[4]} = "Missing '--'" ]]
}

@test "_parse_action_args: parse variable arguments" {
    cat <<EOH >"$work/test.df.sh"
. "$BATS_TEST_DIRNAME/parse_action_args_helper.sh"
pollute_args_and_varargs
_parse_action_args arg1 ... -- arg1value varargs1 varargs2 || exit 1
dump_args_and_varargs
EOH
    run "$install" "$work/test"
    (( status == 0 ))
    (( ${#lines[@]} == 3 ))
    [[ ${lines[0]} = '_args[arg1] => arg1value' ]]
    [[ ${lines[1]} = '_varargs[0] => varargs1' ]]
    [[ ${lines[2]} = '_varargs[1] => varargs2' ]]
}

@test "_parse_action_args: parse flags" {
    cat <<EOH >"$work/test.df.sh"
. "$BATS_TEST_DIRNAME/parse_action_args_helper.sh"
pollute_args_and_varargs
_parse_action_args --flag-on --flag-off -- --flag-on || exit 1
dump_args_and_varargs
EOH
    run "$install" "$work/test"
    (( status == 0 ))
    (( ${#lines[@]} == 2 ))
    [[ ${lines[0]} = '_args[flag-off] => 0' ]]
    [[ ${lines[1]} = '_args[flag-on] => 1' ]]
}

@test "_parse_action_args: parse options" {
    cat <<EOH >"$work/test.df.sh"
. "$BATS_TEST_DIRNAME/parse_action_args_helper.sh"
pollute_args_and_varargs
_parse_action_args --option-1: --option-2: -- --option-2 value || exit 1
dump_args_and_varargs
EOH
    run "$install" "$work/test"
    (( status == 0 ))
    [[ $output = '_args[option-2] => value' ]]
}

@test "_parse_action_args: invalid flags or options" {
    cat <<EOH >"$work/test.df.sh"
. "$BATS_TEST_DIRNAME/parse_action_args_helper.sh"
pollute_args_and_varargs
_parse_action_args -- --invalid-flag && exit 1
dump_args_and_varargs
EOH
    run "$install" "$work/test"
    (( status == 0 ))
    [[ ${output} = "getopt: unrecognized option '--invalid-flag'" ]]
}

@test "_needs_exec" {
    cat <<EOH >"$work/test.df.sh"
_needs_exec bash || exit 2
_needs_exec ____not_exists____
EOH
    run "$install" "$work/test"
    (( status == 1 ))
    [[ ${output} = "missing required command ____not_exists____" ]]
}
