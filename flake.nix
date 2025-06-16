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
        {
          formatter = pkgs.nixfmt-tree.override {
            settings = {
              tree-root-file = "flake.nix";
            };
          };

          packages.default = pkgs.stdenv.mkDerivation (
            finalAttrs:
            let
              pkgJson = (builtins.fromJSON (builtins.readFile ./package.json));
            in
            {
              pname = pkgJson.name;
              version = pkgJson.version;

              src = lib.sources.cleanSource ./.;

              yarnOfflineCache = pkgs.fetchYarnDeps {
                yarnLock = finalAttrs.src + "/yarn.lock";
                hash = "sha256-ecPZvpMQkL2o0X4qx6h1jwQVZrtTC3+Aj7n/SBLRQbo=";
              };

              nativeBuildInputs = with pkgs; [
                yarnConfigHook
                yarnBuildHook
                nodejs
              ];

              installPhase = ''
                mkdir -p $out/lib/${finalAttrs.pname}-${finalAttrs.version}
                cp ./out/prod/* $out/lib/${finalAttrs.pname}-${finalAttrs.version}
              '';

              meta = {
                description = pkgJson.description;
                homepage = "https://publish.obsidian.md/tasks/Introduction";
                license = lib.licenses.mit;
              };
            }
          );

          devShells.default = pkgs.mkShell {
            name = "Obsidian Tasks";
            packages = with pkgs; [
              config.formatter
              corepack
              glibcLocales
            ];
            LOCALE_ARCHIVE = "${pkgs.glibcLocales}/lib/locale/locale-archive";
            LC_NUMERIC = "en_US.UTF-8";
            LANG = "en_US.UTF-8";
          };
        };
    };
}
