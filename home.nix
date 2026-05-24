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
	oterm
        gcc
        nh
        nixfmt
	nixpkgs-fmt
	nix-tree
	nix-output-monitor
        neovim
        direnv
        nix-direnv
        elmPackages.elm
        elmPackages.elm-format
      ];
      media = [
        mpv
        transmission_4
      ];
      security = [
        keepassxc
      ];
      browsers = [
        firefox
      ];
      networking = [
        tailscale
        netcat-openbsd
      ];
      misc = [
        qpwgraph
      ];
    in
    cli-tools ++ dev ++ media ++ security ++ browsers ++ misc ++ networking;

  home.shellAliases = {
    ll = "ls -la";
    l = "eza";
    la = "eza -a";
    "l." = "eza -a | grep -E '^\.'";
    ls = "eza";
    lt = "eza --tree";
    ts = "tailscale --socket=$HOME/.local/share/tailscale/tailscaled.sock";
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "pi-nas" = {
        hostname = "100.77.153.71";
        user = "pi-nas";
        proxyCommand = "nc -x localhost:1055 %h %p";
      };
      # Catch-all for any tailnet IP
      "100.*" = {
        proxyCommand = "nc -x localhost:1055 %h %p";
      };
    };
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

  systemd.user.services.tailscaled = {
    Unit = {
      Description = "Tailscale daemon (userspace networking)";
      After = [ "network-online.target" ];
      Wants = [ "network-online.target" ];
    };
    Service = {
      ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p %h/.local/share/tailscale";
      ExecStart = builtins.concatStringsSep " " [
        "${pkgs.tailscale}/bin/tailscaled"
        "--tun=userspace-networking"
        "--statedir=%h/.local/share/tailscale"
        "--socket=%h/.local/share/tailscale/tailscaled.sock"
        "--port=0"
        "--socks5-server=localhost:1055"
        "--outbound-http-proxy-listen=localhost:1080"
      ];
      Restart = "on-failure";
      RestartSec = "5s";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

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
