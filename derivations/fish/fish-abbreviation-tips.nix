{ lib
, buildFishPlugin
, fetchFromGitHub
,
}:
buildFishPlugin rec {
  pname = "fish-abbreviation-tips";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "gazorby";
    repo = pname;
    rev = "8ed76a62bb044ba4ad8e3e6832640178880df485";
    sha256 = "";
  };

  meta = with lib; {
    description = "Help you remembering your abbreviations";
    homepage = "https://github.com/gazorby/fish-abbreviation-tips";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
  };
}