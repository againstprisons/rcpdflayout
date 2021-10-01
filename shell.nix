{ pkgs ? import <nixpkgs> {}, lib ? pkgs.lib }:

with lib;

pkgs.mkShell {
  buildInputs = with pkgs; [
    ruby
    bundler

    imagemagick
    pngcrush
  ];
}
