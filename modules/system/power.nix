{
  services = {
    # Switches the ACPI platform profile and intel_pstate energy preference
    # together; change with `powerprofilesctl set power-saver|balanced|performance`.
    power-profiles-daemon.enable = true;

    # Intel's thermal daemon keeps the CPU under its limits by throttling
    # gradually instead of letting the firmware hit hard trip points.
    thermald.enable = true;

    # Battery state over D-Bus for the bar, hyprlock and power-profiles-daemon.
    upower.enable = true;
  };

  # The upstream unit's [Install] WantedBy is ignored by NixOS, so without this
  # the daemon is only D-Bus activated and never restores the saved profile
  # or applies its on-battery behaviour until something queries it.
  systemd.services.power-profiles-daemon.wantedBy = [ "graphical.target" ];
}
