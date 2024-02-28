let
  dlaptop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGL2UD0frl9F2OPBiPlSQqxDsuACbAVgwH24F0KT14L delta@dlaptop";
in {
  "test.age".publicKeys = [ dlaptop ];
  "singboxaus.age".publicKeys = [ dlaptop ];
}