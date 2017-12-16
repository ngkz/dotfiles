#!/bin/bash
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
