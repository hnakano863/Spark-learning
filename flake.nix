{
  description = "Shell environment for getting started with Apache Spark";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";

      pythonPackages = pkgs.python37Packages;

      pkgs = import nixpkgs {
        inherit system;
        config.permittedInsecurePackages = [
          "openssl-1.0.2u"
        ];
      };

      spark-buildable = with pkgs; spark.override {
        inherit pythonPackages;
        hadoop = hadoop_2_8;
        jre = jre8;
        RSupport = false;
      };

      py = pythonPackages.python.withPackages (ps: with ps; [
        pandas numpy pyarrow
      ]);

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
        PYSPARK_DRIVER_PYTHON = "${py.interpreter}";
        ARROW_PRE_0_15_IPC_FORMAT = 1;
        buildInputs = [ spark-buildable ];
      };

    };
}
