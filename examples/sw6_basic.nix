{ pkgs, config, inputs, lib, ... }:
{
  shopdev = {
    enable = false;
    # host = "localhost";
    php = {
      # package = "php83";
      # memoryLimit = "8192M";
      # config = [ ]; # This is still WIP
    };
    database = {
      # host = "127.0.0.1";
      # port = 3306;
      # name = "shopware";
      # username = "shopware";
      # password = "shopware";
      # enableMysqlBinLog = false;
    };
    rabbitmq = {
      # enable = false;
      # host = "localhost";
      # port = 5672;
      managementPlugin = {
        # enable = true;
        # port = 15672;
      };
    };
    redis = {
      # enable = false;
      # host = config.shopdev.host;
      # port = 6379;
    };
    adminer = {
      # enable = false;
      # host = config.shopdev.host;
      # port = 8010;
    };
    mailhog = {
      # enable = false;
      # host = config.shopdev.host;
      # port = 8025;
      # apiPort = 8025;
      # smtpPort = 1025;
    };
    search = {
      # enable = false;
      # useElasticSearch = false;
      # host = config.shopdev.host;
      # port = 9200;
      # tcpPort = 9300;
    };
    caddy = {
      # additionalServerAlias = [ "127.0.0.1" ];
    };
    # composer.extraCommands = '''';
  };
}
