{
  description = "Piazza slackbot";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;

  outputs = { self, nixpkgs }: {
    nixosModules = {
      piazza-slackbot = import ./module.nix;
    };
  };
}
