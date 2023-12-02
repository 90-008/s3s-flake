{config, lib, ...}: let
  l = lib // builtins;
  t = l.types;
  cfg = config.services.s3s;
in {
  options = {
    services.s3s = {
      enable = l.mkEnableOption "enable s3s";
      package = l.mkOption {
        type = t.package;
        description = "s3s package to use";
      };
      workingDirectory = l.mkOption {
        type = t.str;
        description = "Path relative to $HOME to use for the working directory of s3s";
        default = ".config/s3s";
      };
      timerDuration = l.mkOption {
        type = t.str;
        description = "The duration of the wait in between s3s executions (systemd value for OnUnitActiveSec)";
        default = "5 min";
      };
    };
  };
  config = l.mkIf cfg.enable {
    systemd.user.timers.s3s = {
      Install = {
        WantedBy = ["timers.target"];
      };
      Unit = {
        Description = "s3s timer";
        Requires = ["s3s.service"];
      };
      Timer = {
        Unit = ["s3s.service"];
        OnBootSec = "1 min";
        OnUnitActiveSec = cfg.period;
      };
    };
    systemd.user.services.s3s = {
      Install = {
        WantedBy = ["default.target"];
      };
      Unit = {
        Description = "s3s";
        ConditionPathExists="%h/${cfg.workingDirectory}/config.txt";
        Wants = ["s3s.timer"];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "${cfg.package}/bin/s3s -r";
        WorkingDirectory = "%h/${cfg.workingDirectory}";
      };
    };
  };
}
