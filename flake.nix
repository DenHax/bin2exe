{
  description = "Devshell for Python with bin2exe development";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        bin2exe = pkgs.writeShellApplication {
          name = "bin2exe";
          runtimeInputs = [ pkgs.python3 ];
          text = ''
            exec ${pkgs.python3}/bin/python3 ${./bin/bin2exe.py} "$@"
          '';
        };

        bin2exe-dev = pkgs.writeShellScriptBin "bin2exe-dev" ''
          cd "${toString ./.}"
          exec ${pkgs.python3}/bin/python3 ./bin/bin2exe.py "$@"
        '';
      in
      {
        packages.bin2exe = bin2exe;
        packages.default = bin2exe;

        apps.bin2exe = {
          type = "app";
          program = "${bin2exe}/bin/bin2exe";
        };
        apps.default = self.apps.${system}.bin2exe;

        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.uv
            (pkgs.python3.withPackages (python-pkgs: [
              python-pkgs.pip
            ]))

            bin2exe-dev
            bin2exe
          ];
        };
      }
    );
}
