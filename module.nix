{ pkgs, lib, config, ... }:

let
  piazza-slackbot = import ./default.nix {
    inherit (cfg)
      piazza_id piazza_email piazza_password slack_token channel bot_name;
  };

  cfg = config.services.piazza-slackbot;
in {
  options.services.piazza-slackbot = {
    enable = lib.mkEnableOption "Enable Piazza Slackbot";

    piazza_id = lib.mkOption {
      type = lib.types.str;
      description = "The suffix of the Piazza URL";
      example = "abcdefgh1234ij";
    };
    piazza_email = lib.mkOption {
      type = lib.types.str;
      description = "Your Piazza email";
      example = "foo@example.com";
    };
    piazza_password = lib.mkOption {
      type = lib.types.str;
      description = "Your Piazza password";
    };
    slack_token = lib.mkOption {
      type = lib.types.str;
      description = "Slack bot token";
    };
    channel = lib.mkOption {
      type = lib.types.str;
      description = "The Slack channel to post in";
      example = "piazza";
    };
    bot_name = lib.mkOption {
      type = lib.types.str;
      description = "The username of the Slackbot";
      example = "piazza_bot";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.user.services.piazza-slackbot = {
      description = "Piazza Bot";
      wantedBy = [ "default.target" ];
      serviceConfig = {
        ExecStart = "${piazza-slackbot}/bin/piazza-slackbot";
        Restart = "on-failure";
        RestartSec = 3;
        RestartPreventExitStatus = 3;
      };
    };
  };
}
