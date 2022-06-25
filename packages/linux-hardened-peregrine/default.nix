{ linux_hardened, stdenv, lib, ... }:

# somehow pkg.overrideAttrs doesn't work
lib.overrideDerivation
  (linux_hardened.override (old: rec {
    inherit stdenv; # make stdenv overridable

    argsOverride = {
      modDirVersion = "${linux_hardened.modDirVersion}-peregrine";
    };

    structuredExtraConfig = old.structuredExtraConfig // (with lib.kernel; {
      LOCALVERSION = freeform "-peregrine";

      # intel-undervolt needs /dev/mem
      DEVMEM = yes;
      STRICT_DEVMEM = yes;
      IO_STRICT_DEVMEM = yes;
    });
  }))
  (old: rec {
    pname = "linux-hardened-peregrine";
    name = "${pname}-${old.version}";

    postConfigure = ''
      echo localmodconfig
      make $makeFlags "''${makeFlagsArray[@]}" LSMOD=${./lsmod} localmodconfig
    '';
    preBuild = ''
      # CCACHE_COMPILERCHECK=mtime fails because the kernel uses custom compiler plugin
      export CCACHE_COMPILERCHECK="%compiler% -v"

      #echo "" | gcc -O2 -march=native -mtune=native -v -E - 2>&1 |grep cc1 |sed -r 's/.*? - -(.*)$/-\1/'
      #i7-8565U
      export KCFLAGS="-march=skylake --param l1-cache-size=32 --param l1-cache-line-size=64 --param l2-cache-size=8192 -mtune=skylake -O2"
    '';
  })
