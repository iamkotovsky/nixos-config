{
  networking.networkmanager.enable = true;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services = {
    blueman.enable = true;
    fwupd.enable = true;
  };
}
