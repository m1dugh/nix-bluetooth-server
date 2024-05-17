{
    config,
    lib,
    pkgs,
    ...
}:
with lib;
let cfg = config.midugh.bluetooth-server;
in {
    options.midugh.bluetooth-server = {
        enable = mkEnableOption "Bluetooth server";

        hostname = mkOption {
            description = ''The hostname for this bluetooth server'';
            type = types.str;
            default = config.networking.hostName;
            example = ''my-bluetooth-server'';
        };
    };

    config = lib.mkIf cfg.enable {

        # services.blueman.enable = true;

        services.xserver = {
            enable = true;
            desktopManager = {
                xterm.enable = false;
                xfce.enable = true;
            };
            displayManager.defaultSession = "xfce";
            displayManager.autoLogin = {
                enable = true;
                user = "root";
            };
        };

        boot = {
            kernelModules = [
                "hci_uart"
                "btbcm"
                "pcieport"
            ];

            initrd.availableKernelModules = [
                "xhci_pci"
                "usbhid"
                "usb_storage"
                "vc4"
            ];

            loader.raspberryPi.firmwareConfig = ''
                dtparam=audio=on
                dtparam=krnbt=on
                '';

            kernelParams = [
                "console=serial0,115200"
                "console=tty1"
                "loglevel=5"
            ];
        };


        hardware = {
            deviceTree.enable = true;

            bluetooth.enable = true;
            raspberry-pi."4" = {
                apply-overlays-dtmerge.enable = true;
                fkms-3d.enable = true;
                xhci.enable = true;
            };
        };
    };
}
