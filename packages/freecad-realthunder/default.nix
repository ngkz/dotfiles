{ lib
, stdenv
, mkDerivation
, fetchFromGitHub
, fetchzip
, callPackage
, pkgs
, cmake
, ninja
, GitPython
, boost
, eigen
, gfortran
, gts
, hdf5
, libGLU
, libXmu
, libf2c
, libredwg
, libspnav
, matplotlib
, medfile
, mpi
, ode
, opencascade-occt
, pivy
, pkg-config
, ply
, pycollada
, pyside2
, pyside2-tools
, python
, pyyaml
, qtbase
, qttools
, qtwebengine
, qtx11extras
, qtxmlpatterns
, scipy
, shiboken2
, soqt
, spaceNavSupport ? stdenv.isLinux
, swig
, vtk
, wrapQtAppsHook
, wrapGAppsHook
, xercesc
, zlib
}:
let
  coin3d-realthunder = callPackage ./coin3d.nix {
    inherit stdenv; # ccache
  };
  pivy-realthunder = pivy.override {
    pkgs = pkgs // {
      coin3d = coin3d-realthunder;
    };
  };
  py-slvs = python.pkgs.callPackage ./py-slvs.nix { };
in
mkDerivation rec {
  pname = "freecad-realthunder";
  version = "2023.01.31";

  srcs = [
    # TODO update script
    (fetchzip {
      url = "https://github.com/realthunder/FreeCAD/archive/refs/tags/2023.01.31-edge.tar.gz";
      hash = "sha256-gUziaW0HdhbNvl6rZz7n18e5f7RTHUyV8FRTkd2uzdE=";
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
      rev = "d8015ce2e466e7b4ec0fb41e86b597093ce00e9f";
      hash = "sha256-Y4SMofosEvbj3CFsLHcyz8y2OZhPdmyQxakPqsYdqHw=";
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
    wrapGAppsHook
  ];

  buildInputs = [
    GitPython # for addon manager
    boost
    coin3d-realthunder
    eigen
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
      ymd = builtins.splitVersion version;
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
    '';

  postFixup = ''
    mv $out/share/doc $out
    ln -s $out/bin/FreeCADLink $out/bin/freecad_link
    ln -s $out/bin/FreeCADCmd $out/bin/freecadcmd
  '';

  meta = with lib; {
    homepage = "https://www.freecadweb.org/";
    description = "An open source parametric 3D CAD modeler (realthunder's version)";
    longDescription = ''
      FreeCAD is a parametric 3D modeler. Parametric modeling
      allows you to easily modify your design by going back into
      your model history and changing its parameters. FreeCAD is
      open source (LGPL license) and completely modular, allowing
      for very advanced extension and customization.

      FreeCAD is multiplatfom, and reads and writes many open
      file formats such as STEP, IGES, STL and others.

      This package contains the FreeCAD fork of realthunder
      (https://github.com/realthunder/FreeCAD/) + the Assembly3 workbench
      (https://github.com/realthunder/FreeCAD_assembly3).

      Do _not_ complain to upstream about issues with this snap!
    '';
    license = licenses.lgpl2Plus;
    platforms = platforms.linux;
  };
}
