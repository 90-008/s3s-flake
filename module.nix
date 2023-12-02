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
      workingDir = l.mkOption {
        type = t.str;
        description = "Path relative to $HOME to use for the working directory of s3s";
        default = ".config/s3s";
      };
    };
  };
  config = l.mkIf cfg.enable {
    systemd.user.services.s3s = {
      Install = {
        WantedBy = ["default.target"];
      };
      Unit = {
        Description = "s3s";
        ConditionPathExists="~/${cfg.workingDir}/config.txt";
      };
      Service = {
        ExecStart = "${cfg.package}/bin/s3s -r -M";
        RootDirectory = "~";
        WorkingDirectory = cfg.workingDir;
        Restart = "on-failure";
        RestartSec = 10;
      };
    };
  };
}
