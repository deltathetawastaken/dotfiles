{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "nu_plugin_dns";
  version = "v1.0.5";
  doCheck = false;

  src = fetchFromGitHub {
    owner = "dead10ck";
    repo = pname;
    rev = version;
    sha256 = "sha256-Qnj0oe+OnxlGoah7kr1ni50iKC0xCQ5fFC2GQ8iHqDc=";
  };

  cargoSha256 = "sha256-JEZ7Ng+woHEkCDzcUUqrQvl9cM7kiUtdLmZUidC3Vxs=";

  meta = with lib; {
    description = "DNS utility for nushell";
    homepage = "https://github.com/dead10ck/nu_plugin_dns";
    license = licenses.mpl20;
    maintainers = [ ];
  };
}