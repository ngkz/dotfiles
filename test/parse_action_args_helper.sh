#!/bin/bash
dump_args_and_varargs() {
    for key in "${!_args[@]}"; do
        echo "_args[$key] => ${_args[$key]}"
    done | sort
    for i in "${!_varargs[@]}"; do
        echo "_varargs[$i] => ${_varargs[$i]}"
    done | sort
}

pollute_args_and_varargs() {
    _args=( [check]="args aren't reset" )
    _varargs=("varargs aren't reset")
}
