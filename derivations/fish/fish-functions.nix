{ stdenv, lib, buildFishPlugin }:

buildFishPlugin rec {
  pname = "my-fish-functions";
  version = "1.0.0";

  src = ./fish-functions; # use local directory

  meta = with stdenv.lib; {
    description = "My custom fish functions";
  };
}
