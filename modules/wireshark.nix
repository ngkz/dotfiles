{ ... }: {
  programs.wireshark.enable = true;
  users.users.user.extraGroups = [
    # Wireshark
    "wireshark"
  ];
}
