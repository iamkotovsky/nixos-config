{
  # The generated hardware file supplies filesystems; no ESP mount is guessed here.
  boot.loader.systemd-boot = {
    enable = true;
    # Keeps the boot menu short and the ESP from filling up with old kernels;
    # older generations stay in the store until nix.gc removes them.
    configurationLimit = 10;
  };
  boot.loader.efi.canTouchEfiVariables = true;

  hardware.enableRedistributableFirmware = true;
}
