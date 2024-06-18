{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, rustPlatform
, marked-man
, coreutils
, vulkan-loader
, wayland
, pkg-config
, udev
, v4l-utils
, dbus
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "wluma";
  version = "unstable-2024-02-29";

  src = fetchFromGitHub {
    owner = "avalsch";
    repo = "wluma";
    rev = "27624132a862af36e7d51c8ca215cf6f2dfbed1d";
    hash = "sha256-C29i+y/J7ABsEewMhQXCHMRpADogzp4PYtL+Ar0CKTw=";
  };

  cargoHash = "sha256-aOdBNIpZqigcQC25bxtAqDSO5nwGzcJ3VC3z6MUgmO8=";

  nativeBuildInputs = [
    pkg-config
    rustPlatform.bindgenHook
  ];

  buildInputs = [
    dbus
    udev
    vulkan-loader
    v4l-utils
  ] ++ lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.CoreGraphics
    darwin.apple_sdk.frameworks.IOKit
  ] ++ lib.optionals stdenv.isLinux [
    wayland
  ];

  meta = with lib; {
    description = "Automatic brightness adjustment based on screen contents and ALS";
    homepage = "https://github.com/avalsch/wluma/tree/als.cmd";
    license = licenses.isc;
    maintainers = with maintainers; [ ];
    mainProgram = "wluma";
  };
}
