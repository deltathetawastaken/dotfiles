{ lib
, buildGoModule
, fetchFromGitHub
}:

buildGoModule rec {
  pname = "opera-proxy";
  version = "1.2.5";

  src = fetchFromGitHub {
    owner = "Snawoot";
    repo = "opera-proxy";
    rev = "v${version}";
    hash = "sha256-ZTebhXmyUPONxcOR7+1qQzGKcGlGfOu2OToFaCgSPCQ=";
  };

  vendorHash = "sha256-IlkMeihvGwuvswOFC8+8ZJCCVWbFnLH51X7Z+VDnZx4=";

  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Standalone client for proxies of Opera VPN";
    homepage = "https://github.com/Snawoot/opera-proxy";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    mainProgram = "opera-proxy";
  };
}
