{ ... }:
{
  age.secrets.email-password-mailbox-org = {
    file = ../secrets/email-password-mailbox-org.age;
    owner = "user";
    group = "users";
    mode = "0400";
  };
}
