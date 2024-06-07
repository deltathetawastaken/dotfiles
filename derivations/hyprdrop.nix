{ lib
, rustPlatform
, fetchFromGitHub
}:

rustPlatform.buildRustPackage rec {
  pname = "hyprdrop";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "kjlo";
    repo = "hyprdrop";
    rev = "v${version}";
    hash = "sha256-QKkXJV8xU3JWbLw87Apfs54BaPXjrr7Uf2gm9I0PXa0=";
  };

  cargoHash = "sha256-TPfEEnK8peO5/SnrUNbaYd8l60V4azqySRWqBhLwl6E=";

  meta = with lib; {
    description = "Rust implementation of Hdrop";
    homepage = "https://github.com/kjlo/hyprdrop";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "hyprdrop";
  };
}
