{ username, ... }:
{
  programs.ssh = {
    enable = true;

    # Re-declare the old defaults explicitly instead of relying on them; they
    # are removed with the `enableDefaultConfig` option in future home-manager.
    enableDefaultConfig = false;
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };

    settings."erem5.erem.kiev.ua" = {
      HostName = "erem5.erem.kiev.ua";
      User = username;
      IdentityFile = "~/.ssh/sea-site_deploy";
    };
  };
}
