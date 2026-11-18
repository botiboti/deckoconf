# Keeps Steam's Game Mode battery charge limit applied in Desktop Mode too.
# Set the limit with the Game Mode slider only: Steam re-applies its own value
# on entering Game Mode, so anything set from Desktop Mode is lost.
{ pkgs, lib, ... }:
let
  defaultLevel = 80; # until Game Mode reports a value

  battery-cap = pkgs.writeShellApplication {
    name = "battery-cap";
    runtimeInputs = [ pkgs.glib.bin ]; # gdbus
    text = ''
      steamosctl=/usr/bin/steamosctl
      state="''${XDG_STATE_HOME:-$HOME/.local/state}/battery-cap"
      mkdir -p "$(dirname "$state")"

      active() { "$steamosctl" get-max-charge-level | grep -o '[0-9]\+'; }
      saved() { cat "$state" 2>/dev/null || echo ${toString defaultLevel}; }
      game_mode() { /usr/bin/systemctl --user is-active --quiet gamescope-session.target; }
      apply() {
        game_mode && return 0
        local level
        level=$(saved)
        if [ "$(active)" != "$level" ]; then
          "$steamosctl" set-max-charge-level "$level"
        fi
      }

      # Game Mode: record Steam's value. Desktop Mode: restore it.
      on_change() {
        if game_mode; then
          echo "$1" > "$state"
          echo "recorded $1% from Game Mode"
        elif [ "$1" != "$(saved)" ]; then
          echo "limit changed to $1%, restoring $(saved)%"
          apply
        fi
      }

      watch() {
        apply
        gdbus monitor --session --dest com.steampowered.SteamOSManager1 \
            --object-path /com/steampowered/SteamOSManager1 |
          while IFS= read -r line; do
            if [[ $line =~ \'MaxChargeLevel\':\ \<([0-9]+)\> ]]; then
              on_change "''${BASH_REMATCH[1]}" || true
            fi
          done &
        gdbus monitor --system --dest org.freedesktop.login1 \
            --object-path /org/freedesktop/login1 |
          while IFS= read -r line; do
            if [[ $line == *"PrepareForSleep (false"* ]]; then
              echo "resumed from sleep"
              apply || true
            fi
          done &
        wait -n
        exit 1 # a monitor died; systemd restarts
      }

      case "''${1:-}" in
        apply)  apply ;;
        watch)  watch ;;
        status)
          if game_mode; then echo "mode:   game"; else echo "mode:   desktop"; fi
          echo "saved:  $(saved)%"
          echo "active: $(active)%" ;;
        *) echo "usage: battery-cap status" >&2; exit 1 ;;
      esac
    '';
  };
in
{
  home.packages = [ battery-cap ];

  # Restarts with each session, so switching modes re-applies the limit.
  systemd.user.services.battery-cap = {
    Unit = {
      Description = "Battery charge limit watcher";
      After = [
        "graphical-session.target"
        "steamos-manager.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${lib.getExe battery-cap} watch";
      Restart = "on-failure";
      RestartSec = "10s";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
