{ ... }:
{
  programs.ssh = {
    enable = true;
    settings."erem5.erem.kiev.ua" = {
      HostName = "erem5.erem.kiev.ua";
      User = "danil";
      IdentityFile = "~/.ssh/sea-site_deploy";
    };
  };
}
