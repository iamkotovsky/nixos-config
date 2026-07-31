{
  networking.networkmanager.enable = true;
  networking.wireless.enable = false;

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  services = {
    blueman.enable = true;
    fwupd.enable = true;
    udisks2.enable = true;
    upower.enable = true;
  };
}
