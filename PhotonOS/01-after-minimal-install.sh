## downloadable via curl -LO https://git.io/fjvTk

##### ALL VARIABLES ARE OPTIONAL #####

SSHAUTHKey="" # warning copy your public here; if not mine will be!
SUPERUSER="rescue" # you may want to replace rescue by your own username (will be member of: docker, ssh and sudo)
IPext="$(curl https://ipinfo.io/ip)"
#WIP TZ="$(curl worldtimeapi.org/api/ip/${IPext}.txt|grep timezone|cut -d' ' -f2)" # ref: http://worldtimeapi.org

##### END OF VARIABLES SECTION #####

## update
tdnf update -y

## install basic tools
tdnf install -y apparmor-profiles apparmor-utils bindutils cronie gawk git haveged ipset iputils socat sudo tar unzip wget

## enable haveged
systemctl enable haveged
systemctl restart haveged

## config timezone
echo "Servers=0.pool.ntp.org 1.pool.ntp.org 2.pool.ntp.org 3.pool.ntp.org" >> /etc/systemd/timesyncd.conf
#WIP timedatectl set-timezone ${TZ}
timedatectl set-ntp 1

## add user
groupmod -g 1000 users
useradd -mu 1000 -G users -s /bin/bash -d /var/srv/${SUPERUSER} ${SUPERUSER}
usermod -aG docker ${SUPERUSER}
usermod -aG sshd ${SUPERUSER}
usermod -aG sudo ${SUPERUSER}

chmod 700 /var/srv/${SUPERUSER}/.

chown :docker /var/srv/.
chmod g+w /var/srv/.

## config ssh client
mkdir /var/srv/${SUPERUSER}/.ssh
curl -o /var/srv/${SUPERUSER}/.ssh/config -L https://gist.githubusercontent.com/jodumont/3fc790a4a4c2657d215a4db4bb0437af/raw/93f42921e436bfdff1b88c6570904b1383f7ddf6/.ssh_config
curl -o /var/srv/${SUPERUSER}/.ssh/authorized_keys -L https://gist.githubusercontent.com/jodumont/2fc29f7be085102c6a00ad9349c00f85/raw/c2f34df4590ce7d98a1e012e67ed3a489c90c78b/id_jodumont.pub
chown -R ${SUPERUSER}:users /var/srv/${SUPERUSER}/.ssh

## config ssh client for root
mkdir /root/.ssh
curl -o /root/.ssh/config -L https://gist.githubusercontent.com/jodumont/3fc790a4a4c2657d215a4db4bb0437af/raw/93f42921e436bfdff1b88c6570904b1383f7ddf6/.ssh_config

## config ssh daemon
curl -o /etc/ssh/sshd_config -L https://git.io/fhhzL
sed -i 's/AllowGroups ssh/AllowGroups sshd/g' /etc/ssh/sshd_config
systemctl restart sshd

## config docker
[[ ! -f /etc/docker/daemon.json ]] && \
mkdir /etc/docker && \
echo -e '{
"data-root": "/var/srv/docker",
"experimental": false,
"live-restore": true,
"no-new-privileges": false,
"userns-remap": "dockremap"
}' > /etc/docker/daemon.json

[[ -z $(grep dockremap /etc/passwd) ]] && \
groupadd -g 500 dockremap && \
useradd -Mu 500 -g 500 -s /bin/false dockremap && \
echo dockremap:$(cat /etc/passwd|grep dockremap|cut -d: -f3):65536 >> /etc/subuid && \
echo dockremap:$(cat /etc/passwd|grep dockremap|cut -d: -f4):65536 >> /etc/subgid

## install docker-compose
curl -L https://github.com/docker/compose/releases/download/$(curl -Ls https://www.servercow.de/docker-compose/latest.php)/docker-compose-$(uname -s)-$(uname -m) > /usr/local/bin/docker-compose
chown root:docker /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

## weekly autoupdate system + autoclean docker
echo -e '
@weekly tdnf update -y
@weekly docker system prune -f
' > /var/spool/cron/root

## USUAL UMASK for SERVER and USER
#sed 's|^UMASK.*|UMASK 022|g' -i /etc/login.defs
#sed 's|^UMASK.*|UMASK 022|g' -i /etc/profile

## secure /var/tmp +tmpfs
rm -Rf {/tmp/,/var/tmp/}{.*,*}
echo -e "
tmpfs /dev/shm tmpfs nodev,nosuid,noexec 0 0
tmpfs /tmp tmpfs nodev,nosuid,size=512M 0 0
/tmp /var/tmp none bind 0 0
" >> /etc/fstab

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

systemctl enable docker

tdnf install -y photon-upgrade
yes|photon-upgrade.sh
