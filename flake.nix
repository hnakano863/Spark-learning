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

      py = pythonPackages.python.withPackages (ps: with ps; [
        pandas numpy pyarrow ipykernel
      ]);

    in with pkgs; {

      packages."${system}" = {

        example-data = stdenvNoCC.mkDerivation {
          name = "example-data";
          inherit (spark) src;

          phases = [ "unpackPhase" "installPhase" ];

          installPhase = ''
            mkdir -p $out/share
            cp $src/README.md $out/share/README.md
            cp $src/examples/src/main/resources/people.json $out/share/people.json
          '';
        };

        spark-buildable = spark.override {
          inherit pythonPackages;
          hadoop = hadoop_2_8;
          jre = jre8;
          RSupport = false;
        };

        pyspark-wrapped = let
          inherit (self.packages."${system}") spark-buildable;
        in runCommand "pyspark-wrapped" {
          buildInputs = [ makeWrapper py spark-buildable ];
        } ''
          mkdir -p $out/bin/
          makeWrapper ${spark-buildable}/bin/pyspark $out/bin/pyspark-wrapped \
            --set PYSPARK_DRIVER_PYTHON ${py.interpreter} \
            --set ARROW_PRE_0_15_IPC_FORMAT 1
        '';

        jupyter-notebook = let

          inherit (self.packages."${system}") spark-buildable;

          definitions.python3 = {
            displayName = "Python 3 (PySpark)";
            argv = [
              py.interpreter
              "-m" "ipykernel_launcher"
              "-f" "{connection_file}"
            ];
            language = "python";
            logo32 = "${py.sitePackages}/ipykernel/resources/logo-32x32.png";
            logo64 = "${py.sitePackages}/ipykernel/resources/logo-64x64.png";
          };

          jupyter-cmd = jupyter.override { inherit definitions; };

        in runCommand "pyspark-jupyter" {
          buildInputs = [ makeWrapper jupyter-cmd py spark-buildable ];
        } ''
          mkdir -p $out/bin/
          makeWrapper ${spark-buildable}/bin/pyspark $out/bin/pyspark-jupyter \
            --set PYSPARK_DRIVER_PYTHON ${jupyter-cmd}/bin/jupyter-notebook \
            --set PYSPARK_DRIVER_PYTHON_OPTS '--no-browser' \
            --set ARROW_PRE_0_15_IPC_FORMAT 1
        '';
      };

      defaultPackage."${system}" = self.packages."${system}".pyspark-wrapped;

    };
}
