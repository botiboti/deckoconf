{ config, pkgs,... }: {
  home.username = "deck";
  home.homeDirectory = "/home/deck";

  home.stateVersion = "25.05"

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    gcc
    nixfmt
    vscodium
    neovim
  ];

  nixpkgs.config.allowunfree = true;
}