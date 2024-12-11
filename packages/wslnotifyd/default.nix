{ fetchFromGitHub
, buildDotnetModule
, dotnetCorePackages
, gtk3
, lib
}:

buildDotnetModule rec {
  pname = "wslnotifyd";
  version = "0.0.0-unstable-2024-09-18";

  src = fetchFromGitHub {
    owner = "ultrabig";
    repo = "WslNotifyd";
    rev = "2c227009f76de1aa52b5cf0ae5c47dff8e446878";
    hash = "sha256-CQ4ZYaiYUE6J1TDYq4GxnNsxsfR1uh1lW0kIm9ZDYik=";
  };

  patches = [
    ./runtimeidentifier.patch
    ./wslnotifydwin-path.patch
    ./make-dst-writable.patch
  ];

  postPatch = ''
    substituteInPlace WslNotifyd/Program.cs \
      --subst-var-by WslNotifydWin "${win}/lib/wslnotifyd-win"
  '';

  projectFile = "WslNotifyd/WslNotifyd.csproj";
  nugetDeps = ./deps-wsl.nix;
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
    nugetDeps = ./deps-win.nix;
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
