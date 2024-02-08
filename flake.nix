{
  description = "SIMD data types and functions";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      haskPkgs = pkgs.haskell.packages.ghc948;
      haskellDeps = hsPkgs : with hsPkgs; [
        vector

        haskell-language-server
      ];
      f = { mkDerivation, lib, llvm
      , base, criterion, deepseq, ghc-prim, primitive, random, vector, basic-cpuid, temporary, primitive-addr
      }:
        let
          dependencies = [ base vector ];
        in mkDerivation {
          pname = "primitive-simd";
          version = "0.1.1.0";
          src = ./.;
          setupHaskellDepends = [ base basic-cpuid temporary ];
          libraryHaskellDepends = [ base ghc-prim primitive vector primitive-addr ];
          libraryPkgconfigDepends = [ llvm ];
          benchmarkHaskellDepends = [ base criterion deepseq random vector ];
          description = "SIMD data types and functions";
          doHaddock = false;
          license = lib.licenses.bsd3;
        };
      drv = haskPkgs.callPackage f {inherit (pkgs.llvmPackages_12) llvm;};
    in {
      packages.default = drv;
      checks.bench = pkgs.haskell.lib.doBenchmark drv;
      devShells.default = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          # nix-direnv
          bashInteractive

          # dev
          ((haskPkgs.ghc.withPackages.override { useLLVM = true; }) haskellDeps)
          llvmPackages_12.libllvm

          # debug
          stylish-haskell
        ];
        buildInputs = [ ];
      };
    });
}
