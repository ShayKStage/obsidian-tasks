{
  description = "Obsidian Tasks";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      nixpkgs,
      systems,
      flake-parts,
      ...
    }@inputs:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [ ];

      flake = { };

      systems = import inputs.systems;
      perSystem =
        {
          config,
          pkgs,
          lib,
          system,
          ...
        }@args:
        let
          formatter = pkgs.nixfmt-tree.override {
            settings = {
              tree-root-file = "flake.nix";
            };
          };
        in
        {
          inherit formatter;

          devShells.default = pkgs.mkShell {
            name = "Obsidian Tasks";
            buildInputs = with pkgs; [
              formatter
              corepack
            ];
          };
        };
    };
}
