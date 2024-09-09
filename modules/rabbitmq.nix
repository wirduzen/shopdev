{ pkgs, config, inputs, lib, ... }:
let
  cfg = config.shopdev;
in
{
  options.shopdev.rabbitmq = {
    enable = lib.mkOption {
      type = lib.types.bool;
      description = ''Enable and configure RabbitMQ via shopdev.'';
      default = false;
    };
    host = lib.mkOption {
      type = lib.types.str;
      description = ''
        RabbitMQ host. Defaults to global host.
        127.0.0.1 can't be used as rabbitmq can't set short node name
      '';
      default = "localhost";
    };
    port = lib.mkOption {
      type = lib.types.int;
      description = ''Sets the RabbitMQ port'';
      default = 5672;
    };
    managementPlugin = {
      enable = lib.mkOption {
        type = lib.types.bool;
        description = ''Enable and configure RabbitMQ via shopdev.'';
        default = true;
      };
      port = lib.mkOption {
        type = lib.types.int;
        description = ''Sets the RabbitMQ management plugin port'';
        default = 15672;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [{
      assertion = ("${cfg.rabbitmq.host}" != "127.0.0.1");
      message = "127.0.0.1 can't be used as rabbitmq host because it can't set short node names. Use localhost instead.";
    }];
    env = {
      RABBITMQ_NODENAME = "rabbit@${cfg.rabbitmq.host}"; #
      RABBITMQ_NODE_PORT = "${toString cfg.rabbitmq.port}";
    };
    services.rabbitmq = {
      enable = cfg.rabbitmq.enable;
      port = cfg.rabbitmq.port;
      managementPlugin = {
        enable = cfg.rabbitmq.managementPlugin.enable;
        port= cfg.rabbitmq.managementPlugin.port;
      };
    };
  };
}
