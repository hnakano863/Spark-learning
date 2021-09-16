{
  description = "A standard dev shell";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let

      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.permittedInsecurePackages = [
          "openssl-1.0.2u"
        ];
      };

    in {

      devShell.x86_64-linux = import ./shell.nix { inherit pkgs; };

    };
}
