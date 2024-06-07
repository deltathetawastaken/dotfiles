{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "hyprdrop";
  version = "unstable-2024-05-12";

  src = fetchFromGitHub {
    owner = "kjlo";
    repo = "hyprdrop";
    rev = "d21001d1589e0f4d3b809a6b6efa18c411421c30";
    hash = "sha256-t/sxLtpPFHOWTSivMdh+7C8Ba4bBObZgjisgSkRcOpc=";
  };

  cargoLock = {
    lockFile = ./Cargo.lock;
    outputHashes = {
      "hyprland-0.4.0-alpha.2" = "sha256-+AkB1ZltdqPn2ZRzU5FIQVWwuvm2TWhnNJnnG/oUIfI=";
    };
  };

  meta = with lib; {
    description = "Rust implementation of Hdrop";
    homepage = "https://github.com/kjlo/hyprdrop";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "hyprdrop";
  };
}
