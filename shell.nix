{ nixpkgs ? import <nixpkgs> {} }:
let
  inherit (nixpkgs) pkgs;

  haskellDeps = ps: with ps; [
    warp
    file-embed
    blaze-builder
  ];

  ghc = pkgs.haskell.packages.ghc901.ghcWithPackages haskellDeps;

  nixPackages = [ ghc ];
in
pkgs.stdenv.mkDerivation {
  name = "env";
  buildInputs = nixPackages;
}

# https://github.com/NixOS/nixpkgs/issues/64603
