{
  description = "Shell environment for getting started with Apache Spark";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

  outputs = { self, nixpkgs }:
    let

      pkgs = import nixpkgs {
        system = "x86_64-linux";
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

      devShell.x86_64-linux = pkgs.mkShell {
        buildInputs = [ spark-buildable ];
      };

    };
}
