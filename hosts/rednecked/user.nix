{ inputs, config, ... }:
let
  inherit (inputs) self;
in
{
  # user
  age.secrets.user-password-hash-rednecked.file = ../../secrets/user-password-hash-rednecked.age;
  users.users.user.passwordFile = config.age.secrets.user-password-hash-rednecked.path;

  # home-manager.users.user = {
  #   imports = with self.homeManagerModules; [
  #   ];
  # };
}

