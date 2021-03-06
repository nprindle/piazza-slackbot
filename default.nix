{ pkgs }:

args@{ piazza_id, piazza_email, piazza_password, slack_token, channel, bot_name }:

let
  std = import (pkgs.fetchFromGitHub {
    owner = "chessai";
    repo = "nix-std";
    rev = "1ea7e46efbd0ce738b27b3e450ebcb1d3571038e";
    sha256 = "1mipd0wjfv65gn637dnj7vzaxkap93im6rhrqy0zr4kxn2ihfkp5";
  });

  python = pkgs.python37;
  python-env = python.withPackages (p: with p; [
    (python.pkgs.buildPythonPackage rec {
      pname = "piazza-api";
      version = "0.11.0";
      src = fetchPypi {
        inherit pname version;
        sha256 = "17w2ma77a86riz36fkgvkpq3rrym4ic09l7ni8ky2bjd61zgz0fr";
      };
      propagatedBuildInputs = [ six requests ];
    })
    (python.pkgs.buildPythonPackage rec {
      pname = "slacker";
      version = "0.14.0";
      src = fetchPypi {
        inherit pname version;
        sha256 = "022ixpjfs566r8880qzwbdk9bxshy52h722w5ch4w4aw0abwbrqs";
      };
      propagatedBuildInputs = [ requests ];
      doCheck = false;
    })
  ]);
in pkgs.stdenv.mkDerivation {
  name = "piazza-slackbot";

  src = pkgs.lib.cleanSource ./.;

  buildInputs = [ pkgs.makeWrapper ];
  buildPhase = ''
    mkdir -p "$out/bin"
    cp "$src"/slackbot.py "$out/bin/.piazza-slackbot-wrapped"

    sed -e ' ${
      std.string.concatMapSep ";" (kv:
        ''s/^${kv._0}[[:space:]]*=[[:space:]]*""/${kv._0} = "${kv._1}"/''
      ) (std.set.toList args)
    } ' -i "$out/bin/.piazza-slackbot-wrapped"
  '';
  installPhase = ''
    makeWrapper \
      "${python-env}/bin/python" \
      "$out"/bin/piazza-slackbot \
      --add-flags "$out/bin/.piazza-slackbot-wrapped"
  '';
}

