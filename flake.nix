{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  inputs.dream2nix.url = "github:nix-community/dream2nix";
  inputs.dream2nix.inputs.nixpkgs.follows = "nixpkgs";
  inputs.src.url = "github:frozenpandaman/s3s";
  inputs.src.flake = false;

  outputs = inp: let
    system = "x86_64-linux";
    pkgs = inp.nixpkgs.legacyPackages.${system};
    package = inp.dream2nix.lib.evalModules {
      packageSets.nixpkgs = pkgs;
      modules = [
        {
          mkDerivation.src = inp.src;
          # Q: why not use the version in the s3s code?
          # A: revision gives more info and context since we check for new commits daily.
          name = "s3s-${inp.src.shortRev}";
          version = inp.src.shortRev;
        }
        ./default.nix
        {
          paths.projectRoot = ./.;
          paths.projectRootFile = "flake.nix";
          paths.package = ./.;
        }
      ];
    };
  in {
    homeManagerModule = {lib, pkgs, ...}: {
      imports = [./module.nix];
      services.s3s.package = lib.mkDefault inp.self.packages.${pkgs.system}.default; 
    };
    packages.${system}.default = package;
  };
}
