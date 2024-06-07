{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "windscribe-proxy";
  version = "1.4.0";

  src = fetchFromGitHub {
    owner = "Snawoot";
    repo = "windscribe-proxy";
    rev = "v${version}";
    hash = "sha256-bVW/cdG1/5WiVZD5yXdkoVqUlYas/CkTD82WANne9gA=";
  };

  vendorHash = "sha256-K1ca//RdFGbNLrLDHsjaCcChHREO/dvOWg7/auRbFhs=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Standalone client for proxies of Windscribe browser extension";
    homepage = "https://github.com/Snawoot/windscribe-proxy";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "windscribe-proxy";
  };
}
