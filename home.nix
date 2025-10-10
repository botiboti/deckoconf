{ config, pkgs,... }: {
  home.username = "deck";
  home.homeDirectory = "/home/deck";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    gcc
    nixfmt
    vscodium
    neovim
    transmission_3
    mpv
    keepassxc
  ];

  home.shellAliases = {
    ll = "ls -la";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true; # Optional: enables Bash completion
  };

  targets.genericLinux.enable  = true;

  nixpkgs.config.allowunfree = true;
}