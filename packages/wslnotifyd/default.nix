{ fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, gtk3
, lib
, coreutils
, iconv
, gnused
}:

buildDotnetModule rec {
  pname = "wslnotifyd";
  version = "0.0.0-unstable-2025-02-14";

  src = fetchFromGitHub {
    owner = "ultrabig";
    repo = "WslNotifyd";
    rev = "fb2aca84b766a0cedf64fbbcb5b2e33436b1f19a";
    hash = "sha256-xgMK1lTbghDhpXREctGqSiT0GxgSNMx/R7KsZfd6nbk=";
  };

  patches = [
    ./wslnotifydwin-path.patch
    ./make-dst-writable.patch
  ];

  postPatch = ''
    substituteInPlace WslNotifyd/Program.cs \
      --subst-var-by WslNotifydWin "${win}/lib/wslnotifyd-win"
  '';

  projectFile = "WslNotifyd/WslNotifyd.csproj";
  nugetDeps = ./deps-wsl.json;
  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.aspnetcore_8_0;
  runtimeDeps = [ gtk3 win ];

  win = buildDotnetModule {
    inherit version src patches dotnet-sdk dotnet-runtime;
    pname = "wslnotifyd-win";
    runtimeId = "win-x64";
    projectFile = "WslNotifydWin/WslNotifydWin.csproj";
    executables = [ ];
    selfContainedBuild = true;
    nugetDeps = ./deps-win.json;
    postInstall = ''
      for script in $out/lib/wslnotifyd-win/scripts/*.sh; do
        # /bin/wslpath
        wrapProgram "$script" --prefix PATH : /bin:${lib.makeBinPath [coreutils iconv gnused]}
      done
    '';
  };

  postInstall = ''
    mkdir -p $out/share/dbus-1/services
    sed "s|Exec = .*|Exec = $out/bin/WslNotifyd|" resources/dbus-service/org.freedesktop.Notifications.service >$out/share/dbus-1/services/org.freedesktop.Notifications.service
    mkdir -p $out/lib/systemd/user
    sed "s|ExecStart = .*|ExecStart = $out/bin/WslNotifyd|" resources/systemd-user-units/WslNotifyd.service >$out/lib/systemd/user/WslNotifyd.service
  '';

  meta = with lib; {
    homepage = "https://github.com/ultrabig/WslNotifyd";
    description = "WslNotifyd is an implementation of the Desktop Notifications Specification using Windows native functionality.";
    license = licenses.mit;
  };
}
