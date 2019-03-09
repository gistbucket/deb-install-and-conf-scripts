## downloadable via curl -LO https://git.io/fp2uF

DOMAIN=""
EMAIL="hostmaster@$DOMAIN"
USER=""
TZ=""

## install git
tdnf install -y git

[[ -n $DOMAIN ]] && \
cd /etc && \
git config --global user.email "$EMAIL"
git config --global user.name "root"
git init .
git add -A
git commit -m "FreshInstall"

## update
tdnf update -y

cd /etc
git add -A
git commit -m "update"

## install basic tools
tdnf install -y apparmor-profiles bindutils cronie gawk haveged iputils sudo tar unzip wget

cd /etc
git add -A
git commit -m "basic tools"

## enable haveged
systemctl enable haveged
systemctl restart haveged

cd /etc
git add -A
git commit -m "enable haveged"

## config timezone
echo "Servers=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org" >> /etc/systemd/timesyncd.conf
timedatectl set-timezone $TZ
timedatectl set-ntp 1

cd /etc
git add -A
git commit -m "set timezone"

## add user
groupmod -g 1000 users
sed "s|100|1000|g" -i /etc/default/useradd
useradd -mu 1000 -G users -s /bin/bash $USER
usermod -aG docker $USER
usermod -aG sshd $USER
usermod -aG sudo $USER
mkdir -p $(grep HOME /etc/default/useradd|cut -d= -f2)/$USER/.ssh
chown -R $USER.users $(grep HOME /etc/default/useradd|cut -d= -f2)/$USER/.ssh

cd /etc
git add -A
git commit -m "add superuser"

## config docker
[[ ! -f /etc/docker/daemon.json ]] && \
mkdir /etc/docker && \
echo -e '{
"experimental": false,
"live-restore": true,
"no-new-privileges": false,
"userns-remap": "dockremap"
}' > /etc/docker/daemon.json

[[ -z $(grep dockremap /etc/passwd) ]] && \
groupadd -g 32 dockremap && \
useradd -Mu 32 -g 32 -s /bin/false dockremap && \
echo dockremap:$(cat /etc/passwd|grep dockremap|cut -d: -f3):65536 >> /etc/subuid && \
echo dockremap:$(cat /etc/passwd|grep dockremap|cut -d: -f4):65536 >> /etc/subgid

## install docker-compose
curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chown root:docker /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

cd /etc
git add -A
git commit -m "config docker daemon"

## weekly autoupdate system + autoclean docker
echo -e '
@weekly tdnf update -y
@weekly docker system prune -f
' > /var/spool/cron/root

## /home in /var/srv
mv /home /var/srv
mkdir /home
echo -e "
/var/srv/home /home none bind,noatime,nodev,noexec,nosuid 0 0
" >> /etc/fstab

## /var/lib/docker in /var/srv
rm -Rf /var/lib/docker
mkdir -p /var/srv/{data,docker} /var/lib/docker
echo -e "
/var/srv/docker /var/lib/docker none bind,noatime,nodev,noexec,nosuid 0 0
" >> /etc/fstab
chmod g=rwx /var/srv/.
chown root:docker /var/srv/.
chown $USER:users /var/srv/data/.
mount -a

## secure /var/tmp +tmpfs
rm -Rf {/tmp/,/var/tmp/}{.*,*}
echo -e "
/tmp /var/tmp none bind,noatime,nodev,noexec,nosuid 0 0
tmpfs /dev/shm tmpfs noatime,nodev,nosuid,noexec 0 0" >> /etc/fstab
mount -a

### UMASK
sed "s|umask 027|umask 022|g" -i /etc/profile

### tweak system for redis
echo "kernel/mm/transparent_hugepage/enabled = never" > /etc/sysfs.conf
echo "vm.overcommit_memory=1" > /etc/sysctl.d/redis.conf

### HARDEN
### AUTH-9286
sed 's|^PASS_MIN_DAYS.*|PASS_MIN_DAYS 7|g' -i /etc/login.defs
sed 's|^PASS_MAX_DAYS.*|PASS_MAX_DAYS 180|g' -i /etc/login.defs

### SHLL-6220
echo -e "
# set a 5 min timeout policy for bash shell
TMOUT=300
readonly TMOUT
export TMOUT" >> /etc/profile

### FILE-6430
modprobe -r cramfs freevxfs hfs hfsplus jffs2 squashfs udf
echo -e "## lynis recommandation FILE-6430
install cramfs /bin/true
install freevxfs /bin/true
install hfs /bin/true
install hfsplus /bin/true
install jffs2 /bin/true
install squashfs /bin/true
install udf /bin/true
" > /etc/modprobe.d/blacklist_filesystem

### STRG-1840, 1841, 1842
modprobe -r usb-storage
echo -e "## lynis recommandation STRG-1840
blacklist usb-storage
install usb-storage /bin/true
" > /etc/modprobe.d/blacklist_usb

### STRG-1846
modprobe -r firewire-core firewire_ohci
echo -e "## lynis recommandation STRG-1846
blacklist firewire-core
install firewire_core /bin/true
install firewire_ohci /bin/true
" > /etc/modprobe.d/blacklist_firewire

### BANN-7126
echo -e "********************************************************************
*                                                                  *
* This system is for the use of authorized users only.  Usage of   *
* this system may be monitored and recorded by system personnel.   *
*                                                                  *
* Anyone using this system expressly consents to such monitoring   *
* and is advised that if such monitoring reveals possible          *
* evidence of criminal activity, system personnel may provide the  *
* evidence from such monitoring to law enforcement officials.      *
*                                                                  *
********************************************************************" > /etc/issue
cp -f /etc/issue /etc/issue.net

txnf install -y photon-upgrade

systemctl enable docker
reboot
