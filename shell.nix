{ pkgs ? import <nixpkgs> {} }:

let
  python = pkgs.python37;
  python-env = with pkgs; python.withPackages (p: with p; [
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
in pkgs.mkShell {
  buildInputs = [ python-env ];
}

