# Auto-mounts removable drives (e.g. USB sticks) and notifies (quickshell bar) on insert/removal.
{
  services.udiskie = {
    enable = true;
    tray = "auto";
    notify = true;
  };
}
