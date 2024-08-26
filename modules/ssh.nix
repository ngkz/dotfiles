# SSH
# See also: home/ssh.nix
{ pkgs, lib, ... }:
let
  inherit (lib.ngkz) rot13;
in
{
  programs.ssh = {
    enableAskPassword = true;
    askPassword = "${pkgs.ngkz.gnome-ssh-askpass3}/libexec/gnome-ssh-askpass3";
    startAgent = true;
    knownHosts = {
      "github.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCj7ndNxQowgcQnjshcLrqPEiiphnt+VTTvDP6mHBL9j1aNUkY4Ue1gvwnGLVlOhGeYrnZaMgRK6+PKCUXaDbC7qtbW8gIkhL7aGCsOr/C56SJMy/BCZfxd1nWzAOxSDPgVsmerOBYfNqltV9/hWCqBywINIR+5dIg6JTJ72pcEpEjcYgXkE2YEFXV1JHnsKgbLWNlhScqb2UmyRkQyytRLtL+38TGxkxCflmO+5Z8CSSNY7GidjMIZ7Q4zMjA2n1nGrlTDkzwDCsw+wqFPGQA179cnfGWOWRVruj16z6XyvxvjJwbz0wQZ75XK5tKSb7FNyeIEs4TT4jk+S4dhPeAUC5y+bDYirYgM4GC7uEnztnZyaVWQ7B381AK4Qdrwt51ZqExKbQpTUNn+EjqoTwvqNj4kqx5QUCI0ThS/YkOxJCXmPUWZbhjpCg56i+2aB6CmK2JGhn57K5mj0MNdBXA4/WnwH6XoPWJzK5Nyu2zB3nAZp+S5hpQs+p1vN1/wsjk=";
      "peregrine.falcon-nunki.ts.net".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC6fsHDfhNCH1nCHQ3QH45pD/5ZQVyZYe2zvvD0dWunrUSujVOme0D8RIDl9oMy2Mp7x+W7oYaJE6hCoSMSg2JJVjZyNQC313JAUsH0lUHkGCmiNUwKxGkpgR7T3Y5IRYoN6jdWpmIext/ry0Ig2WjUTdR0m10J4OAi1ZFa6dOsXHMm4NvU5xO58UqB/fMTaTFX2aghGknD2ChcwkI7W6xIcPgVXG9UNo7rh84KmDDrtxjCns01vRwrCU4RYgWmWGOhpF89vbfkPA38sa70p2/g9TasdUo0Hm+X0i0UMOr0fdkol0UuOnLw8gnU7JQvpI9pVSwj4M+l1SjmKFl5GD8QJyrbekkQNlFBWuMQoZxtweJL6FD12xjlLsk4kmbhyNCtUXIWClVxKuYCbg7hChB8Dm9MJg0/gj/0K72oC21YAmYOuxTBZU0DdvhAuPtj0oLL7+F0j6xqlFtOIgr81zqVod4ilpDvXlo58Vlov5C8Yy6w+/q53qTblipzJoloOJJj0RVZUpkDrd1cmAxyRJ9n7wxnkrbBPftEwGSWeQ43FF23RycXEYYzrb7ZDfL6dMjYUhd5OB856ITDFK7HwPvRoyqv6jRO3gI1zjEQbPhIjdmsImVe9Tik2EYUzL8KxeVJSqiyodYpagTtMRBHn+jrXrnUp4WWaarpoDL0iXOIJQ==";
      "gitlab.com".publicKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCsj2bNKTBSpIYDEGk9KxsGh3mySTRgMtXL583qmBpzeQ+jqCMRgBqB98u3z++J1sKlXHWfM9dyhSevkMwSbhoR8XIq/U0tCNyokEi/ueaBMCvbcTHhO7FcwzY92WK4Yt0aGROY5qX2UKSeOvuP4D6TPqKF1onrSzH9bx9XUf2lEdWT/ia1NEKjunUqu1xOB/StKDHMoX4/OKyIzuS0q/T1zOATthvasJFoPrAjkohTyaDUz2LN5JoH839hViyEG82yB+MjcFV5MU3N1l1QL3cVUCh93xSaua1N85qivl+siMkPGbO5xR/En4iEY6K2XPASUEMaieWVNTRCtJ4S8H+9";
      "${rot13 "[gfhxhon.avjnfr.arg]:49224"}".publicKey = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBF9L6WVElJnpK7zRmZdk7aYJc0z4zrZcXd0AjkqMPBnpXGL6V3pIGdDl1fRuGeeHGCif958fLcpOSzU+v2g5uEI=";
      "rednecked.falcon-nunki.ts.net".publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILPl2FFAlSd2EMv+Cx6Floei91AmTUix119a7Npm3axF";
    };
  };
}
