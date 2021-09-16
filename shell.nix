{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  spark-buildable = spark.override {
    hadoop = hadoop_2_8;
    jre = jre8;
    pythonPackages = python37Packages;
    RSupport = false;
  };

in mkShell {

  buildInputs = [ spark-buildable ];

}
