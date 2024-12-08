{ config, ... }: {
  services.cloudflare-dyndns = {
    enable = true;
    domains = ["f2l.cc"];
    ipv6 = true;
    apiTokenFile = config.age.secrets.cloudflare-api-key.path;
  };

  age.secrets.cloudflare-api-key.file = ../../secrets/cloudflare-api-key.age;
}
