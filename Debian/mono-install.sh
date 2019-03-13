#!/bin/bash -eu

### VARIABLES
apps="jackett, lidarr, sonarr, radarr"
appsFolder="/opt"
dataFolder="/srv"
source .env

## OS
[[ -n $(grep jessie /etc/*release) ]] && \
    OS="debian" &&\
    DISTRO="jessie"
[[ -n $(grep stretch /etc/*release) ]] && \
    OS="debian" &&\
    DISTRO="stretch"
[[ -n $(grep xenial /etc/*release) ]] && \
    OS="ubuntu" &&\
    DISTRO="xenial"
[[ -n $(grep bionic /etc/*release) ]] && \
    OS="ubuntu" &&\
    DISTRO="bionic"

[[ -z $OS ]] && \
echo "Sorry your OS is not supported." && \
exit 0

### LOCALE US UTF-8
locale-gen en_US.UTF-8
update-locale en_US.UTF-8

### TIMEZONE
[[ -z $TZ ]] && \
TZ="UTC"
timedatectl set-timezone $TZ
timedatectl set-ntp 1

## CLEAN
apt autoremove --purge -y
apt install -y --no-install-recommends apparmor apparmor-profiles apparmor-profiles-extra apparmor-utils arpon byobu haveged
if [ $(systemd-detect-virt) != "lxc" ];
    ### APPARMOR
    [[ $(grep GRUB_CMDLINE_LINUX /etc/default/grub) != *"apparmor"* ]] && \
        sed -e 's/^GRUB_CMDLINE_LINUX="\(.*\)"$/GRUB_CMDLINE_LINUX="\1 apparmor=1 security=apparmor"/' -i /etc/default/grub

    ### CGROUP
    [[ $(grep GRUB_CMDLINE_LINUX /etc/default/grub) != *"cgroup_enable"* ]] && \
        sed -e 's/^GRUB_CMDLINE_LINUX="\(.*\)"$/GRUB_CMDLINE_LINUX="\1 cgroup_enable=memory swapaccount=1 panic_on_oops=1 panic=5"/' -i /etc/default/grub
    grub-update
fi

### TOOLS
apt install -y --no-install-recommends acl apt-listchanges apt-transport-https bzip2 ca-certificates chrony coreutils curl debsums dirmngr gnupg iptables ipset net-tools sudo sysfsutils unattended-upgrades unzip wget

### SOURCE
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C5CDF62C7AE05CC847657390C10E11090EC0E438
echo "deb http://download.mono-project.com/repo/$OS $DISTRO main" | tee /etc/apt/sources.list.d/mono-official.list
echo "deb https://mediaarea.net/repo/deb/$OS $DISTRO main" | tee /etc/apt/sources.list.d/mediaarea.list
apt update

## INSTALL
apt-get install -y --no-install-recommends ca-certificates-mono libcurl4-openssl-dev jq mediainfo mono-devel mono-vbnc python sqlite3

groupadd -g multimedia

for app in $apps; do
    [[ $app == lidarr ]] && id=7878 && appArg="Lidarr/Lidarr.exe --log-file=/var/log/$app.log --nobrowser --server-datafolder=$data --webservice-interface=any"
    [[ $app == sonarr ]] && id=8989 && appArg="NzbDrone/NzbDrone.exe --log-file=/var/log/$app.log --nobrowser --server-datafolder=$data --webservice-interface=any"
    [[ $app == radarr ]] && id=8686 && appArg="Radarr/Radarr.exe --log-file=/var/log/$app.log --nobrowser --server-datafolder=$data --webservice-interface=any"
    [[ $app == jackett ]] && id=9117 && appArg="Jackett/JackettConsole.exe --DataFolder=$data"

    useradd -Ng multimedia -Mu $id -s /bin/false $app

    echo -e "[Service]"
    User=$app
    Group=multimedia
    Type=Simple
    ExecStart=/usr/bin/mono /$appsFolder/$appArg
    TimeoutStopSec=20
    KillMode=process
    Restart=on-failure

    [Install]
    WantedBy=multi-user.target" | tee /lib/systemd/system/$app.service
    systemctl enable $app.service
    systemctl start $app.service
done
