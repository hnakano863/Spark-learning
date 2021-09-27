{
  description = "Shell environment for getting started with Apache Spark";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.permittedInsecurePackages = [
          "openssl-1.0.2u"
        ];
      };

      spark-buildable = with pkgs; spark.override {
        hadoop = hadoop_2_8;
        jre = jre8;
        pythonPackages = python37Packages;
        RSupport = false;
      };

    in {

      packages."${system}".example-data = pkgs.stdenvNoCC.mkDerivation {
        name = "example-data";
        inherit (spark-buildable) src;

        phases = [ "unpackPhase" "installPhase" ];

        installPhase = ''
          mkdir -p $out/share
          cp $src/README.md $out/share/README.md
          cp $src/examples/src/main/resources/people.json $out/share/people.json
        '';
      };

      devShell."${system}" = pkgs.mkShell {
        buildInputs = [ spark-buildable ];
      };

    };
}
