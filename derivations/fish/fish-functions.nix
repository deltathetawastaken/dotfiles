{ stdenv, buildFishPlugin }:

buildFishPlugin rec {
  pname = "my-fish-functions";
  version = "1.0.0";

  src = ./fish-functions;

  meta = with stdenv.lib; {
    description = "My custom fish functions";
  };
}
