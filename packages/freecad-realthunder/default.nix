{ lib
, callPackage
, pkgs
, cmake
, doxygen
, eigen
, fetchFromGitHub
, fmt
, ngkz  # for passthru.tests
, gfortran
, gts
, hdf5
, libGLU
, libXmu
, libf2c
, libredwg
, libsForQt5
, libspnav
, medfile
, mpi
, ninja
, ode
, opencascade-occt_7_6
, pkg-config
, python3Packages
, runCommand  # for passthru.tests
, spaceNavSupport ? stdenv.isLinux
, stdenv
, swig
, vtk
, wrapGAppsHook3
, xercesc
, zlib
}:

let
  opencascade-occt = opencascade-occt_7_6;
  boost = python3Packages.boost;
  inherit (libsForQt5)
    qtbase
    qttools
    qtwebengine
    qtx11extras
    qtxmlpatterns
    soqt
    wrapQtAppsHook;
  inherit (python3Packages)
    gitpython
    matplotlib
    pivy
    ply
    pycollada
    pyside2
    pyside2-tools
    python
    pyyaml
    scipy
    shiboken2;
  coin3d-realthunder = callPackage ./coin3d.nix { };
  pivy-realthunder = pivy.override {
    pkgs = pkgs // {
      coin3d = coin3d-realthunder;
    };
  };
  py-slvs = python.pkgs.callPackage ./py-slvs.nix { };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "freecad-realthunder";
  version = "2024.10.03";

  srcs = [
    # TODO update script
    (fetchFromGitHub {
      owner = "realthunder";
      repo = "FreeCAD";
      rev = "a9810d509a6f112b5ac03d4d4831b67e6bffd5b7";
      hash = "sha256-aKsjUsJcjSSgi44ztz9zRSrEvfSq/KpbLyw8pXLapU4=";
      name = "freecad";
    })
    (fetchFromGitHub {
      owner = "realthunder";
      repo = "fcad-branding";
      rev = "814727302be9c34a7642fca28815af00c3526e2f";
      hash = "sha256-aHdrPpTQrEYkNgfnUnFLPaMEy8EEReYqufrepSJNZHI=";
      name = "branding";
    })
    (fetchFromGitHub {
      owner = "realthunder";
      repo = "FreeCAD_assembly3";
      rev = "b6d2ecd35a9a12a9422106cd2af58c296788f183";
      hash = "sha256-yIDv9RV2V9BMyFjp4TjAjgH3lUeejrBhV9BMzPpJI40=";
      name = "asm3";
    })
  ];
  sourceRoot = "freecad";

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    pyside2-tools
    gfortran
    wrapQtAppsHook
    wrapGAppsHook3
  ];

  buildInputs = [
    gitpython # for addon manager
    boost
    coin3d-realthunder
    doxygen
    eigen
    fmt
    gts
    hdf5
    libGLU
    libXmu
    libf2c
    matplotlib
    medfile
    mpi
    ode
    opencascade-occt
    pivy-realthunder
    ply # for openSCAD file support
    pycollada
    pyside2
    pyside2-tools
    python
    pyyaml # (at least for) PyrateWorkbench
    qtbase
    qttools
    qtwebengine
    qtxmlpatterns
    scipy
    shiboken2
    soqt
    swig
    vtk
    xercesc
    zlib
  ] ++ lib.optionals spaceNavSupport [
    libspnav
    qtx11extras
  ];

  propagatedBuildInputs = [
    py-slvs
  ];

  cmakeFlags = [
    "-Wno-dev" # turns off warnings which otherwise makes it hard to see what is going on
    "-DBUILD_FLAT_MESH:BOOL=ON"
    "-DBUILD_QT5=ON"
    "-DSHIBOKEN_INCLUDE_DIR=${shiboken2}/include"
    "-DSHIBOKEN_LIBRARY=Shiboken2::libshiboken"
    ("-DPYSIDE_INCLUDE_DIR=${pyside2}/include"
      + ";${pyside2}/include/PySide2/QtCore"
      + ";${pyside2}/include/PySide2/QtWidgets"
      + ";${pyside2}/include/PySide2/QtGui"
    )
    "-DPYSIDE_LIBRARY=PySide2::pyside2"
  ];

  # This should work on both x86_64, and i686 linux
  preBuild = ''
    export NIX_LDFLAGS="-L${gfortran.cc}/lib64 -L${gfortran.cc}/lib $NIX_LDFLAGS";
  '';

  # Their main() removes PYTHONPATH=, and we rely on it.
  preConfigure = ''
    sed '/putenv("PYTHONPATH/d' -i src/Main/MainGui.cpp

    qtWrapperArgs+=(--prefix PYTHONPATH : "$PYTHONPATH")
  '';

  qtWrapperArgs = [
    "--set COIN_GL_NO_CURRENT_CONTEXT_CHECK 1"
    "--prefix PATH : ${libredwg}/bin"
  ];

  preFixup =
    let
      ymd = builtins.splitVersion finalAttrs.version;
    in
    ''
      branding=../../branding/asm3
      sed -i \
          -e 's/^Name.*=FreeCAD/& Link Branch/' \
          -e 's/^Icon=.*/Icon=freecad_link/' \
          -e 's/^Exec=FreeCAD/&Link/' \
          $out/share/applications/org.freecadweb.FreeCAD.desktop
      cp -a $branding/icons $out/share
      cp -Lr $branding/branding $out/share
      chmod u+w -R $out/share/branding
      mv $out/share/branding/branding.xml $out/bin
      sed -Ei \
          -e 's/_FC_VERSION_MAJOR_/${builtins.head ymd}/g' \
          -e 's/_FC_VERSION_MINOR_/${builtins.elemAt ymd 1}${builtins.elemAt ymd 2}/g' \
          -e 's/_FC_VERSION_MINOR2_/${builtins.elemAt ymd 1}.${builtins.elemAt ymd 2}/g' \
          -e 's/_FC_BUILD_DATE_/${builtins.concatStringsSep "" ymd}/g' \
          -e "s@<(WindowIcon|SplashScreen|AboutImage|SplashGif)>@&$out/share/branding/@" \
          $out/bin/branding.xml
      mv $out/bin/FreeCAD $out/bin/FreeCADLink

      cp -a ../../asm3 $out/Mod/Assembly3
      # causes fixup failure
      chmod +w $out/Mod/Assembly3/freecad/asm3/translations
      rm -f $out/Mod/Assembly3/freecad/asm3/translations/update_translation.sh
      chmod -w $out/Mod/Assembly3/freecad/asm3/translations
    '';

  postFixup = ''
    mv $out/share/doc $out
    ln -s $out/bin/FreeCADLink $out/bin/freecad_link
    ln -s $out/bin/FreeCADCmd $out/bin/freecadcmd
  '';

  passthru.tests = {
    # Check that things such as argument parsing still work correctly with
    # the above PYTHONPATH patch. Previously the patch used above changed
    # the `PyConfig_InitIsolatedConfig` to `PyConfig_InitPythonConfig`,
    # which caused the built-in interpreter to attempt (and fail) to doubly
    # parse argv. This should catch if that ever regresses and also ensures
    # that PYTHONPATH is still respected enough for the FreeCAD console to
    # successfully run and check that it was included in `sys.path`.
    python-path = runCommand "freecad-test-console"
      {
        nativeBuildInputs = [ ngkz.freecad ];
      } ''
      HOME="$(mktemp -d)" PYTHONPATH="$(pwd)/test" FreeCADCmd --log-file $out -c "if not '$(pwd)/test' in sys.path: sys.exit(1)" </dev/null
    '';
  };

  meta = {
    homepage = "https://www.freecad.org";
    description = "General purpose Open Source 3D CAD/MCAD/CAx/CAE/PLM modeler";
    longDescription = ''
      FreeCAD is an open-source parametric 3D modeler made primarily to design
      real-life objects of any size. Parametric modeling allows you to easily
      modify your design by going back into your model history and changing its
      parameters.

      FreeCAD allows you to sketch geometry constrained 2D shapes and use them
      as a base to build other objects. It contains many components to adjust
      dimensions or extract design details from 3D models to create high quality
      production ready drawings.

      FreeCAD is designed to fit a wide range of uses including product design,
      mechanical engineering and architecture. Whether you are a hobbyist, a
      programmer, an experienced CAD user, a student or a teacher, you will feel
      right at home with FreeCAD.

      This package contains the FreeCAD fork of realthunder
      (https://github.com/realthunder/FreeCAD/) + the Assembly3 workbench
      (https://github.com/realthunder/FreeCAD_assembly3).

      Do _not_ complain to upstream about issues with this snap!
    '';
    license = lib.licenses.lgpl2Plus;
    maintainers = with lib.maintainers; [ viric gebner AndersonTorres ];
    platforms = lib.platforms.linux;
  };
})
