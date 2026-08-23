# Auto-mounts removable drives (e.g. USB sticks) and notifies via mako on insert/removal.
{
  services.udiskie = {
    enable = true;
    tray = "auto";
    notify = true;
  };
}
