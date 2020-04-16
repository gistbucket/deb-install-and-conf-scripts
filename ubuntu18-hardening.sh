#!/bin/sh -e

MOD="bluetooth bnep btusb firewire-core floppy n_hdlc net-pf-31 pcspkr soundcore thunderbolt usb-midi usb-storage"
PACKAGE_REMOVE="apport* avahi* beep pastebinit popularity-contest rsh* talk* telnet* tftp* whoopsie xinetd yp-tools ypbind"
PACKAGE_INSTALL="acct apparmor-profiles apparmor-utils debsums haveged libpam-tmpdir rkhunter systemd-coredump vlock"

## Configuration files
COREDUMPCONF='/etc/systemd/coredump.conf'
DISABLEFS='/etc/modprobe.d/disablefs.conf'
DISABLEMOD='/etc/modprobe.d/disablemod.conf'
DISABLENET='/etc/modprobe.d/disablenet.conf'
JOURNALDCONF='/etc/systemd/journald.conf'
LIMITSCONF='/etc/security/limits.conf'
RESOLVEDCONF='/etc/systemd/resolved.conf'
RKHUNTERCONF='/etc/default/rkhunter'
SECURITYACCESS='/etc/security/access.conf'
SSHDFILE='/etc/ssh/sshd_config'
SYSCTL='/etc/sysctl.conf'
SYSTEMCONF='/etc/systemd/system.conf'
USERCONF='/etc/systemd/user.conf'

if [ -f /lib/systemd/systemd-random-seed ]; then
    /lib/systemd/systemd-random-seed load
    /lib/systemd/systemd-random-seed save
fi

export TERM=linux
export DEBIAN_FRONTEND=noninteractive

APT="apt-get --assume-yes"

## Set timezone
timedatectl set-timezone $(curl -s worldtimeapi.org/api/ip/$(curl -s ifconfig.me/ip)|cut -d\" -f16)

## Install etckeeper
if [ ! -f $HOME/packages.installed ]; then
    apt list --installed > $HOME/packages.installed
fi
if ! -f $HOME/.gitconfig  2>/dev/null 1>&2; then
    echo -e "[user]
    	name = $USER
	    email = $USER@$(hostname -f)" > .gitconfig
fi
apt update
$APT install curl etckeeper wget

## Disable net services
NET="dccp sctp rds tipc"
for disable in $NET; do
if ! grep -q "$disable" "$DISABLENET" 2> /dev/null; then
    echo "install $disable /bin/true" >> "$DISABLENET"
fi
done

## Mount and FSTAB
sed -i '/floppy/d' /etc/fstab

## If not physical
#if [ ! $(lshw -class system|grep vendor) ]; then
#fi
## If LXC
if [ $(systemd-detect-virt) == lxc ] 2>/dev/null 1>&2; then
    if ! mount|grep /home|grep nosuid,nodev,noexec 2>/dev/null 1>&2; then
        echo "/home parition is missing or have wrong option (nosuid,nodev,noexec)"
    fi
    # etckeeper not working with nosuid on /tmp
    if ! mount|grep /tmp|grep nodev 2>/dev/null 1>&2; then
        echo "/tmp parition is missing or have wrong option (nosuid,nodev,noexec)"
    fi
    if ! mount|grep /var/log|grep nosuid,nodev,noexec 2>/dev/null 1>&2; then
        echo "/var/log parition is missing or have wrong option (nosuid,nodev,noexec)"
    fi
    if ! mount|grep /var/log/audit|grep nosuid,nodev,noexec 2>/dev/null 1>&2; then
        echo "/var/log/audit parition is missing or have wrong option (nosuid,nodev,noexec)"
    fi
    # etckeeper not working with nosuid on /tmp
    if ! mount|grep /tmp 2>/dev/null 1>&2; then
        echo 'tmpfs /tmp tmpfs nodev,size=512M 0 0' >> /etc/fstab
    fi
else
    if grep -q '[[:space:]]/boot[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab; then
        grep '[[:space:]]/boot[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab | sed 's/defaults/defaults,nosuid,nodev/g' -i /etc/fstab
    fi
    if grep -q '[[:space:]]/home[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab; then
        grep '[[:space:]]/home[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab | sed 's/defaults/defaults,nosuid,nodev/g' -i /etc/fstab
    fi
    if grep -q '[[:space:]]/var/log[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab; then
        grep '[[:space:]]/var/log[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab | sed 's/defaults/defaults,nosuid,nodev,noexec/g' -i /etc/fstab
    fi
    if grep -q '[[:space:]]/var/log/audit[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab; then
        grep '[[:space:]]/var/log/audit[[:space:]].*defaults[[:space:]]0 0$' /etc/fstab | sed 's/defaults/defaults,nosuid,nodev,noexec/g' -i /etc/fstab
    fi
    if ! grep -i '/tmp' /etc/fstab 2>/dev/null 1>&2; then
        echo 'tmpfs /tmp tmpfs nodev,nosuid,size=512M 0 0' >> /etc/fstab
    fi
    if ! grep -i '/var/tmp' /etc/fstab 2>/dev/null 1>&2; then
        echo '/tmp /var/tmp none bind 0 0' >> /etc/fstab
    fi
    if ! grep -i '/proc' /etc/fstab 2>/dev/null 1>&2; then
        echo 'none /proc proc rw,nosuid,nodev,noexec,relatime,hidepid=2 0 0' >> /etc/fstab
    fi
fi

if ! grep -i '/dev/shm' /etc/fstab 2>/dev/null 1>&2; then
    echo 'tmpfs /dev/shm tmpfs nodev,nosuid,noexec 0 0' >> /etc/fstab
fi
if ! grep -i '/run/shm' /etc/fstab 2>/dev/null 1>&2; then
    echo 'none /run/shm tmpfs rw,noexec,nosuid,nodev 0 0' >> /etc/fstab
fi
if ! grep -i '/var/tmp' /etc/fstab 2>/dev/null 1>&2; then
    echo '/tmp /var/tmp none bind 0 0' >> /etc/fstab
fi

rm -Rf /{tmp,var/tmp}/{.*,*}
mount -a

## Disable FS
FS="cramfs freevxfs jffs2 hfs hfsplus squashfs udf vfat"
for disable in $FS; do
    if ! grep -q "$disable" "$DISABLEFS" 2> /dev/null; then
        echo "install $disable /bin/true" >> "$DISABLEFS"
    fi
done

## System conf
sed -i 's/^#DumpCore=.*/DumpCore=no/' "$SYSTEMCONF"
sed -i 's/^#CrashShell=.*/CrashShell=no/' "$SYSTEMCONF"
sed -i 's/^#DefaultLimitCORE=.*/DefaultLimitCORE=0/' "$SYSTEMCONF"
sed -i 's/^#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1024/' "$SYSTEMCONF"
sed -i 's/^#DefaultLimitNPROC=.*/DefaultLimitNPROC=1024/' "$SYSTEMCONF"

sed -i 's/^#DefaultLimitCORE=.*/DefaultLimitCORE=0/' "$USERCONF"
sed -i 's/^#DefaultLimitNOFILE=.*/DefaultLimitNOFILE=1024/' "$USERCONF"
sed -i 's/^#DefaultLimitNPROC=.*/DefaultLimitNPROC=1024/' "$USERCONF"

## JounralD
sed -i 's/^#Storage=.*/Storage=persistent/' "$JOURNALDCONF"
sed -i 's/^#ForwardToSyslog=.*/ForwardToSyslog=yes/' "$JOURNALDCONF"
sed -i 's/^#Compress=.*/Compress=yes/' "$JOURNALDCONF"

if dpkg -l | grep prelink 1> /dev/null; then
    "$(command -v prelink)" -ua 2> /dev/null
    $APT purge prelink
fi

## Upgrade
apt update
$APT --with-new-pkgs upgrade
apt -qq clean
apt -qq autoremove

## Apt configure
if ! grep '^Acquire::http::AllowRedirect' /etc/apt/apt.conf.d/* ; then
    echo 'Acquire::http::AllowRedirect "false";' >> /etc/apt/apt.conf.d/01-vendor-ubuntu
    else
    sed -i 's/.*Acquire::http::AllowRedirect*/Acquire::http::AllowRedirect "false";/g' "$(grep -l 'Acquire::http::AllowRedirect' /etc/apt/apt.conf.d/*)"
fi
if ! grep '^APT::Get::AllowUnauthenticated' /etc/apt/apt.conf.d/* ; then
    echo 'APT::Get::AllowUnauthenticated "false";' >> /etc/apt/apt.conf.d/01-vendor-ubuntu
    else
    sed -i 's/.*APT::Get::AllowUnauthenticated.*/APT::Get::AllowUnauthenticated "false";/g' "$(grep -l 'APT::Get::AllowUnauthenticated' /etc/apt/apt.conf.d/*)"
fi
if ! grep '^APT::Periodic::AutocleanInterval "7";' /etc/apt/apt.conf.d/*; then
    echo 'APT::Periodic::AutocleanInterval "7";' >> /etc/apt/apt.conf.d/10periodic
    else
    sed -i 's/.*APT::Periodic::AutocleanInterval.*/APT::Periodic::AutocleanInterval "7";/g' "$(grep -l 'APT::Periodic::AutocleanInterval' /etc/apt/apt.conf.d/*)"
fi
if ! grep '^APT::Install-Recommends' /etc/apt/apt.conf.d/*; then
    echo 'APT::Install-Recommends "false";' >> /etc/apt/apt.conf.d/01-vendor-ubuntu
    else
    sed -i 's/.*APT::Install-Recommends.*/APT::Install-Recommends "false";/g' "$(grep -l 'APT::Install-Recommends' /etc/apt/apt.conf.d/*)"
fi
if ! grep '^APT::Get::AutomaticRemove' /etc/apt/apt.conf.d/*; then
    echo 'APT::Get::AutomaticRemove "true";' >> /etc/apt/apt.conf.d/01-vendor-ubuntu
    else
    sed -i 's/.*APT::Get::AutomaticRemove.*/APT::Get::AutomaticRemove "true";/g' "$(grep -l 'APT::Get::AutomaticRemove' /etc/apt/apt.conf.d/*)"
fi
if ! grep '^APT::Install-Suggests' /etc/apt/apt.conf.d/*; then
    echo 'APT::Install-Suggests "false";' >> /etc/apt/apt.conf.d/01-vendor-ubuntu
    else
    sed -i 's/.*APT::Install-Suggests.*/APT::Install-Suggests "false";/g' "$(grep -l 'APT::Install-Suggests' /etc/apt/apt.conf.d/*)"
fi
if ! grep '^Unattended-Upgrade::Remove-Unused-Dependencies' /etc/apt/apt.conf.d/*; then
    echo 'Unattended-Upgrade::Remove-Unused-Dependencies "true";' >> /etc/apt/apt.conf.d/50unattended-upgrades
    else
    sed -i 's/.*Unattended-Upgrade::Remove-Unused-Dependencies.*/Unattended-Upgrade::Remove-Unused-Dependencies "true";/g' "$(grep -l 'Unattended-Upgrade::Remove-Unused-Dependencies' /etc/apt/apt.conf.d/*)"
fi

## Host
echo "sshd : ALL : ALLOW" > /etc/hosts.allow
echo "ALL: LOCAL, 127.0.0.1" >> /etc/hosts.allow
echo "ALL: ALL" > /etc/hosts.deny
chmod 644 /etc/hosts.allow
chmod 644 /etc/hosts.deny

## Root Access
if ! grep -E '^+\s:\sroot\s:\s127.0.0.1$|^:root:127.0.0.1' "$SECURITYACCESS"; then
    sed -i 's/^#.*root.*:.*127.0.0.1$/+:root:127.0.0.1/' "$SECURITYACCESS"
fi
echo "console" > /etc/securetty
systemctl mask debug-shell.service

## Sysctl
wget -q https://raw.githubusercontent.com/JOduMonT/Configs/master/etc/sysctl.conf -O "$SYSCTL"
sed -i '/net.ipv6.conf.eth0.accept_ra_rtr_pref/d' "$SYSCTL"
for n in $(arp -n -a | awk '{print $NF}' | sort | uniq); do
    echo "net.ipv6.conf.$n.accept_ra_rtr_pref = 0" >> "$SYSCTL"
done
if [ -f /sys/module/nf_conntrack/parameters/hashsize ]; then
    echo 1048576 > /sys/module/nf_conntrack/parameters/hashsize
fi
chmod 0600 "$SYSCTL"

## limits
sed -i 's/^# End of file*//' "$LIMITSCONF"
  { echo '* hard maxlogins 10'
    echo '* hard core 0'
    echo '* soft nproc 512'
    echo '* hard nproc 1024'
    echo '# End of file'
  } >> "$LIMITSCONF"

## Remove
for deb_remove in $PACKAGE_REMOVE; do
$APT purge "$deb_remove"
done
$APT purge "$(dpkg -l | grep '^rc' | awk '{print $2}')"

## Disable Modules
for disable in $MOD; do
    if ! grep -q "$disable" "$DISABLEMOD" 2> /dev/null; then
        echo "install $disable /bin/true" >> "$DISABLEMOD"
    fi
done

## DNS
sed -i "s/^#FallbackDNS=.*/FallbackDNS=1.1.1.1/" "$RESOLVEDCONF"
sed -i "s/^#DNSSEC=.*/DNSSEC=allow-downgrade/" "$RESOLVEDCONF"
sed -i "s/^#DNSOverTLS=.*/DNSOverTLS=opportunistic/" "$RESOLVEDCONF"
sed -i '/^hosts:/ s/files dns/files resolve dns/' /etc/nsswitch.conf

## Apport
if command -v gsettings 2>/dev/null 1>&2; then
    gsettings set com.ubuntu.update-notifier show-apport-crashes false
fi
if command -v ubuntu-report 2>/dev/null 1>&2; then
    ubuntu-report -f send no
fi
if [ -f /etc/default/apport ]; then
    sed -i 's/enabled=.*/enabled=0/' /etc/default/apport
    systemctl stop apport.service
    systemctl mask apport.service
fi

if dpkg -l | grep -E '^ii.*popularity-contest' 2>/dev/null 1>&2; then
    $APT purge popularity-contest
fi

## Core Dump
if test -f "$COREDUMPCONF"; then
    sed -i 's/^#Storage=.*/Storage=none/' "$COREDUMPCONF"
    sed -i 's/^#ProcessSizeMax=.*/ProcessSizeMax=0/' "$COREDUMPCONF"
fi

## motd news
if test -f /etc/default/motd-news; then
    sed -i 's/ENABLED=.*/ENABLED=0/' /etc/default/motd-news
    systemctl mask motd-news.timer
fi

## users
for users in games gnats irc list news sync uucp; do
    userdel -r "$users" 2> /dev/null
done

## suid
for p in /bin/fusermount /bin/mount /bin/ping /bin/ping6 /bin/su /bin/umount /usr/bin/bsd-write /usr/bin/chage /usr/bin/chfn /usr/bin/chsh /usr/bin/mlocate /usr/bin/mtr /usr/bin/newgrp /usr/bin/pkexec /usr/bin/traceroute6.iputils /usr/bin/wall /usr/sbin/pppd; do
    if [ -e "$p" ]; then
        oct=$(stat -c "%a" $p |sed 's/^4/0/')
        ug=$(stat -c "%U %G" $p)
        dpkg-statoverride --remove $p 2> /dev/null
        dpkg-statoverride --add "$ug" "$oct" $p 2> /dev/null
        chmod -s $p
    fi
done
grep -v '^#' /etc/shells | while read -r suidshells; do
    if [ -x "$suidshells" ]; then
        chmod -s "$suidshells"
    fi
done

## sshd
awk '$5 >= 3071' /etc/ssh/moduli > /etc/ssh/moduli.tmp
mv /etc/ssh/moduli.tmp /etc/ssh/moduli

sed -i '/HostKey.*ssh_host_dsa_key .*/d' "$SSHDFILE"
sed -i '/KeyRegenerationInterval .*/d' "$SSHDFILE"
sed -i '/ServerKeyBits .*/d' "$SSHDFILE"
sed -i '/UseLogin .*/d' "$SSHDFILE"
sed -i 's/.*X11Forwarding.*/X11Forwarding no/' "$SSHDFILE"
sed -i 's/.*LoginGraceTime .*/LoginGraceTime 20/' "$SSHDFILE"

sed -i '/^# .*/d' "$SSHDFILE"
sed -i '/^#\t.*/d' "$SSHDFILE"

if grep 100[0-9] /etc/passwd 2> /dev/null; then
    sed -i 's/.*PermitRootLogin .*/PermitRootLogin no/' "$SSHDFILE"
fi

sed -i 's/.*UsePrivilegeSeparation .*/UsePrivilegeSeparation sandbox/' "$SSHDFILE"
sed -i 's/.*Banner .*/Banner \/etc\/issue.net/' "$SSHDFILE"
sed -i 's/.*Subsystem .*sftp.*/Subsystem sftp internal-sftp/' "$SSHDFILE"
sed -i 's/.*Compression .*/Compression no/' "$SSHDFILE"

sed -i 's/.*LogLevel .*/LogLevel VERBOSE/' "$SSHDFILE"
if ! grep -q "^LogLevel" "$SSHDFILE" 2> /dev/null; then
    echo "LogLevel VERBOSE" >> "$SSHDFILE"
fi

sed -i 's/.*PrintLastLog .*/PrintLastLog yes/' "$SSHDFILE"
if ! grep -q "^PrintLastLog" "$SSHDFILE" 2> /dev/null; then
    echo "PrintLastLog yes" >> "$SSHDFILE"
fi

sed -i 's/.*IgnoreUserKnownHosts .*/IgnoreUserKnownHosts yes/' "$SSHDFILE"
if ! grep -q "^IgnoreUserKnownHosts" "$SSHDFILE" 2> /dev/null; then
    echo "IgnoreUserKnownHosts yes" >> "$SSHDFILE"
fi

if passwd --status root|cut -d' ' -f2|grep P 2> /dev/null; then
    sed -i 's/.*PermitEmptyPasswords .*/PermitEmptyPasswords no/' "$SSHDFILE"
fi
for user in $(grep 100[0-9] /etc/passwd|cut -d: -f1); do
    if ! grep -q "^PermitEmptyPasswords" "$SSHDFILE" 2> /dev/null; then
        if passwd --status $user|cut -d' ' -f2|grep P 2> /dev/null; then
            sed -i 's/.*PermitEmptyPasswords .*/PermitEmptyPasswords no/' "$SSHDFILE"
        fi
    fi
done
#echo "PermitEmptyPasswords no" >> "$SSHDFILE"

if ! grep sudo /etc/group|cut -d: -f4 2> /dev/null; then
    sed -i 's/.*AllowGroups .*/AllowGroups sudo/' "$SSHDFILE"
    if ! grep -q "^AllowGroups" "$SSHDFILE" 2> /dev/null; then
        echo "AllowGroups sudo" >> "$SSHDFILE"
    fi
fi

sed -i 's/.*MaxAuthTries .*/MaxAuthTries 4/' "$SSHDFILE"
if ! grep -q "^MaxAuthTries" "$SSHDFILE" 2> /dev/null; then
    echo "MaxAuthTries 4" >> "$SSHDFILE"
fi

sed -i 's/.*ClientAliveInterval .*/ClientAliveInterval 300/' "$SSHDFILE"
if ! grep -q "^ClientAliveInterval" "$SSHDFILE" 2> /dev/null; then
    echo "ClientAliveInterval 300" >> "$SSHDFILE"
fi

sed -i 's/.*ClientAliveCountMax .*/ClientAliveCountMax 0/' "$SSHDFILE"
if ! grep -q "^ClientAliveCountMax" "$SSHDFILE" 2> /dev/null; then
    echo "ClientAliveCountMax 0" >> "$SSHDFILE"
fi

sed -i 's/.*PermitUserEnvironment .*/PermitUserEnvironment no/' "$SSHDFILE"
if ! grep -q "^PermitUserEnvironment" "$SSHDFILE" 2> /dev/null; then
    echo "PermitUserEnvironment no" >> "$SSHDFILE"
fi

sed -i 's/.*KexAlgorithms .*/KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256/' "$SSHDFILE"
if ! grep -q "^KexAlgorithms" "$SSHDFILE" 2> /dev/null; then
    echo 'KexAlgorithms curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256' >> "$SSHDFILE"
fi

sed -i 's/.*Ciphers .*/Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr/' "$SSHDFILE"
if ! grep -q "^Ciphers" "$SSHDFILE" 2> /dev/null; then
    echo 'Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes256-ctr' >> "$SSHDFILE"
fi

sed -i 's/.*Macs .*/Macs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256/' "$SSHDFILE"
if ! grep -q "^Macs" "$SSHDFILE" 2> /dev/null; then
    echo 'Macs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256' >> "$SSHDFILE"
fi

sed -i 's/.*MaxSessions .*/MaxSessions 2/' "$SSHDFILE"
if ! grep -q "^MaxSessions" "$SSHDFILE" 2> /dev/null; then
    echo "MaxSessions 2" >> "$SSHDFILE"
fi

sed -i 's/.*UseDNS .*/UseDNS no/' "$SSHDFILE"
if ! grep -q "^UseDNS" "$SSHDFILE" 2> /dev/null; then
    echo "UseDNS no" >> "$SSHDFILE"
fi

sed -i 's/.*StrictModes .*/StrictModes yes/' "$SSHDFILE"
if ! grep -q "^StrictModes" "$SSHDFILE" 2> /dev/null; then
    echo "StrictModes yes" >> "$SSHDFILE"
fi

sed -i 's/.*MaxStartups .*/MaxStartups 10:30:60/' "$SSHDFILE"
if ! grep -q "^MaxStartups" "$SSHDFILE" 2> /dev/null; then
    echo "MaxStartups 10:30:60" >> "$SSHDFILE"
fi

sed -i 's/.*HostbasedAuthentication .*/HostbasedAuthentication no/' "$SSHDFILE"
if ! grep -q "^HostbasedAuthentication" "$SSHDFILE" 2> /dev/null; then
    echo "HostbasedAuthentication no" >> "$SSHDFILE"
fi

for deb_install in $PACKAGE_INSTALL; do
    $APT install --no-install-recommends "$deb_install"
done

sed -i 's/^CRON_DAILY_RUN=.*/CRON_DAILY_RUN="yes"/' "$RKHUNTERCONF"
sed -i 's/^APT_AUTOGEN=.*/APT_AUTOGEN="yes"/' "$RKHUNTERCONF"
rkhunter --propupd

mv ubuntu18-hardening.sh ubuntu18-hardening.done
