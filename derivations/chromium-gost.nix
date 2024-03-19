{ stdenv
, lib
, dpkg-deb
, fetchurl
, autoPatchelfHook
, wrapGAppsHook
, flac
, gnome2
, harfbuzzFull
, nss
, snappy
, xdg-utils
, xorg
, alsa-lib
, atk
, cairo
, cups
, curl
, dbus
, expat
, fontconfig
, freetype
, gdk-pixbuf
, glib
, gtk3
, libX11
, libxcb
, libXScrnSaver
, libXcomposite
, libXcursor
, libXdamage
, libXext
, libXfixes
, libXi
, libXrandr
, libXrender
, libXtst
, libdrm
, libnotify
, libopus
, libpulseaudio
, libuuid
, libxshmfence
, mesa
, nspr
, pango
, systemd
, at-spi2-atk
, at-spi2-core
, libqt5pas
, qt6
, vivaldi-ffmpeg-codecs
}:


stdenv.mkDerivation rec {
  name = "chromium-gost";
  version = "122.0.6261.128";

  src = fetchurl {
    url = "https://github.com/deemru/Chromium-Gost/releases/download/${version}/chromium-gost-${version}-linux-amd64.deb";
    hash = "";
  };

  nativeBuildInputs = [
    dpkg-deb
    autoPatchelfHook
    qt6.wrapQtAppsHook
    wrapGAppsHook
  ];

  buildInputs = [
    flac
    harfbuzzFull
    nss
    snappy
    xdg-utils
    xorg.libxkbfile
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    curl
    dbus
    expat
    fontconfig.lib
    freetype
    gdk-pixbuf
    glib
    gnome2.GConf
    gtk3
    libX11
    libXScrnSaver
    libXcomposite
    libXcursor
    libXdamage
    libXext
    libXfixes
    libXi
    libXrandr
    libXrender
    libXtst
    libdrm
    libnotify
    libopus
    libuuid
    libxcb
    libxshmfence
    mesa
    nspr
    nss
    pango
    stdenv.cc.cc.lib
    libqt5pas
    qt6.qtbase
  ];

  unpackPhase = ''
    mkdir -p $TMP
    mkdir -p $out/bin
    mkdir -p $out/share
    dpkg -x $src $TMP
  '';

  installPhase = ''
    cp -r $TMP/opt/chromium $out
    cp -r $TMP/usr/share $out/share
    substituteInPlace $out/share/applications/chromium-gost.desktop --replace /usr/ $out/
    substituteInPlace $out/share/menu/chromium-gost --replace /opt/ $out/
    substituteInPlace $out/share/gnome-control-center/default-apps/chromium-gost.xml --replace /opt/ $out/
  '';

  runtimeDependencies = map lib.getLib [
    libpulseaudio
    curl
    systemd
    vivaldi-ffmpeg-codecs
  ] ++ buildInputs;

  meta = with lib; {
    description = "Chromium Fork with GOST support";
    homepage = "https://www.cryptopro.ru/products/chromium-gost";
    license = licenses.unfree;
    maintainers = with maintainers; [];
    platforms = [ "x86_64-linux" ];
  };
}
