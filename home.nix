{ config, pkgs, ... }:
{
  home.username = "deck";
  home.homeDirectory = "/home/deck";

  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  home.packages =
    with pkgs;
    let
      cli-tools = [
        btop
        eza
        fzf
        wezterm
        claude-code
      ];
      dev = [
        gcc
        nixfmt
        neovim
        elmPackages.elm
        elmPackages.elm-format
      ];
      media = [
        mpv
        transmission_3
      ];
      security = [
        keepassxc
      ];
      browsers = [
        firefox
      ];
      misc = [
        qpwgraph
      ];
    in
    cli-tools ++ dev ++ media ++ security ++ browsers ++ misc;

  home.shellAliases = {
    ll = "ls -la";
    l = "eza";
    la = "eza -a";
    "l." = "eza -a | grep -E '^\.'";
    ls = "eza";
    lt = "eza --tree";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true; # Optional: enables Bash completion
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      nonylene.dark-molokai-theme
      vscodevim.vim
      yzhang.markdown-all-in-one
      jnoortheen.nix-ide
    ];
  };

  #  services.ollama = {
  #    enable = true;
  #    # Optional: override description (mkForce wins)
  #    # description = lib.mkForce "Ollama LLM server";
  #
  #    # GPU acceleration for Steam Deck
  #    environmentVariables = {
  #      HSA_OVERRIDE_GFX_VERSION = "10.3.1";
  #      ROCR_VISIBLE_DEVICES = "0";
  #    };
  #
  #    # Auto-start on login
  #    # acceleration = false;  # CPU fallback; set true if ROCm works
  #  };

  targets.genericLinux.enable = true;

  xdg = {
    enable = true;
    mime.enable = true;
    systemDirs.data = [
      "/home/deck/.nix-profile/share"
      "/nix/var/nix/profiles/default/share"
    ];
  };

  nixpkgs.config.allowUnfree = true;
}
