let
  cassini = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzNCD7++dMfrELY3JS8gT2tP0oM6g/AKgN0X4BHseLd cassini.internal";
  huygens = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIrEHF8tSPneinr0H4Yyrq6sXZPnBsvT5ppgLMfilZ/a huygens.internal";
  titan = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDvMwIhpQO6mAVEPBx086dCM/rwi55sNftXq64Ehn552 titan";
in
{
  "secrets/cassini.internal.key.age".publicKeys = [
    titan
    cassini
  ];
  "secrets/huygens.internal.key.age".publicKeys = [
    titan
    huygens
  ];
  "secrets/titan.internal.key.age".publicKeys = [ titan ];
}
