# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
  
  let
    unstableTarball =
      fetchTarball
        https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
    
  in 
  {
    imports =
      [ # Include the results of harware scan.
        /etc/nixos/hardware-configuration.nix
        # add home-manager is an updated fashion (see nixos.wiki/wiki/Home_Manager)
        "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/release-19.09.tar.gz}/nixos"
      ];

    nixpkgs.config = {
      packageOverrides = pkgs: {
        unstable = import unstableTarball {
          config = config.nixpkgs.config;
          };
      };
      allowUnfree = true;
      allowBroken = true;
    }; 
    
  

  # LUKS encrypted partition needs decrypted
  boot.initrd.luks.devices = [
   {
    name = "root";
    device = "/dev/sda2";
    preLVM = true;
   }
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  #trying to get resume from suspend working
  boot.kernelParams = ["iommu=soft" "idle=nomwait"];

  networking.hostName = "nixos"; # Define your hostname.
  #networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
  
  powerManagement.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "us";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "US/Eastern";
  

  environment = {
    shells = [
      "${pkgs.bash}/bin/bash"
      "${pkgs.fish}/bin/fish"
    ];

    etc = with pkgs; {
      "jdk11".source = jdk11;
     # "jetbrains.jdk".source = jetbrainsjdk;
    };

  variables = {
    EDITOR = pkgs.lib.mkOverride 0 "vim";
    BROWSER = pkgs.lib.mkOverride 0 "chromium";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
    systemPackages = with pkgs; [
     
     #TERMINAL/libs
     coreutils
     wget
     vim
     tree
     man
     unzip
     zip
     xorg.xkill
     ripgrep-all
     fish
     youtube-dl
     visidata
     mkpasswd
     chromedriver
     geckodriver
     stow
     gitAndTools.gitFull
     entr
     fd
     gitAndTools.gitFull
     exa
     rclone
     mcron
     asciidoctor
     pandoc
     unstable.webkitgtk
     jdk11
     python37Full
         

     #Containers/Docker
     docker
     docker-compose


     #NIXOS SPECIFIC
     #lorri #lorri service should automatically download
     direnv #for lorri (service)

     #APPS
     chromium
     dbeaver
     pencil
     vlc
     slack
     fondo
     calibre
     pithos
     vocal
     torrential
     shutter
     inkscape
     blender
     unetbootin
     hexchat
     xmind
     gitkraken 
     libreoffice
     gnome3.dconf-editor
     vscodium
     jetbrains.pycharm-community
     gcolor3
     unstable.jetbrains.idea-community
     treesheets
     inkscape
     

     #ELEMENTARY APPS
     unstable.minder

     #CLOJURE
     clojure
     leiningen
     jetbrains.jdk
     boot
    ];
  };
  
  

  #configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:
  #
  # will download lori
  services.lorri.enable = true;


  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  #sound.enable = true;
  hardware.pulseaudio.enable = true;
  
  services.tlp.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable touchpad support.
  services.xserver.libinput.enable = true;
  
  # Enable the Gnome desktop environment
  #services.xserver.displayManager.gdm.enable = true;
  #services.xserver.displayManager.gdm.wayland = false;
  #services.xserver.desktopManager.gnome3.enable = true;

  # Enable the Elementary OS Pantheon Desktop Environment.
  services.xserver.desktopManager = { pantheon.enable = true;
                                      default = "elementary";};
  services.xserver.displayManager.lightdm.enable = true;
  services.xserver.displayManager.auto.enable = true;
  services.xserver.displayManager.auto.user = "ben";

  services.pantheon.contractor.enable = true;

  #ability to set themes via home-manager
  services.dbus.packages = with pkgs; [gnome3.dconf];
  
  users.mutableUsers = false;
  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ben = { 
    isNormalUser = true;
    home = "/home/ben";
    shell = pkgs.fish;
    extraGroups = ["wheel" "video" "audio" "disk" "networkmanager"];
    hashedPassword = "$6$PG6zSaJ3kiXexR$wqSjTiGuV64lNIo5Hz6.X3BRQD2R124Kv4EwP1YeJRz0LwfLkLcShmVljeO8jDzYU/PZS5W3oQsxnwo/WeEKE.";
    uid = 1000;
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?


  ##*********************  HOME MANAGER **********************************##
  #                                                                        #
  ##########################################################################i
  

  home-manager.users.ben = {pkgs, ...  }: {
  
  #nix didn't like this fonts line
  #fonts.fontconfig.enable = true;
  programs.info.enable = true;

  home.packages = with pkgs; [
    capitaine-cursors
    #capitane-icons TODO
    papirus-icon-theme
  
  ];

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  ## Pantheon desktop environment - make module TODO
  
  dconf.settings = {

  "org/gnome/desktop/interface" = {
   cursor-theme = "capitaine-cursors";
   icon-theme = "ePapirus";
   #icon-theme = "elementary";
   show-battery-percentage = true;
  };

  "org/gnome/desktop/privacy" = {
  remove-old-temp-files = true;
  remove-old-trash-files = true;
  };

  "org/gnome/desktop/screensaver" = {
  idle-inactivation-enabled = false;
  lock-enabled = false;
  };

  "org/gnome/settings-daemon/plugins/color" = {
  night-light-enabled = true;
  };

  "org/gnome/settings-daemon/plugins/power" = {
   ambient-enabled = false;
   power-button-action = "hibernate"; 
   sleep-inactive-ac-timeout = 1200;
   sleep-inactive-ac-type = "suspend";
   sleep-inactive-battery-timeout = 900;
   sleep-inactive-battery-type = "suspend";
  };

  "org/pantheon/desktop/gala/appearance" = {
   button-layout = "close,minimize,maximize";
  };
  
  "org/pantheon/desktop/gala/behavior" = {
   hotcorner-topright = "open-launcher";
   hotcorner-bottomleft = "show-workspace-view";
   #hotcorner-topright
   hotcorner-bottomright = "switch-to-workspace-last";
  };

  "io/elementary/files/preferences" = {
   default-viewmode = "miller_columns";
  };

  "io/elementary/desktop/wingpanel/applications-menu" = {
   use-category = true;
  };

  "net/launchpad/plank/docks/dock1" = {
   dock-items = [
     "gala-multitaskingview.dockitem"
     "io.elementary.files.dockitem"
     "io.elementary.switchboard.dockitem"
     "pencil.dockitem"
     "XMind.dockitem"
     "Hexchat.dockitem"
     "idea-community.dockitem"
     "chromium-browser.dockitem"
     "io.elementary.terminal.dockitem"
     ];
   icon-size = 48; #look at 48
   zoom-enabled = true;
   zoom-percent = 125;
  };
 };  
  
  
};
}
