# This file contains code based on hlissner/dotfiles by Henrik Lissner:
# The MIT License (MIT)

# Copyright (c) 2016-2021 Henrik Lissner.

# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:

# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
# CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
# TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

{ lib }: 
let
  inherit (builtins)  pathExists readDir;
  inherit (lib) mapAttrs' nameValuePair hasSuffix removeSuffix;
in {
  loadModuleDir = root:
    mapAttrs' (
      name: type:
        let path = root + "/${name}"; in
        if type == "directory" && pathExists (path + "/default.nix") then
          nameValuePair name (import path)
        else if type == "regular" && hasSuffix ".nix" name then
          nameValuePair (removeSuffix ".nix" name) (import path)
        else
          throw "${path} is not a module"
    ) (readDir root);
}
