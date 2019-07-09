#!/bin/bash

apt install --no-install-recommends -y rkhunter

echo "
ROTATE_MIRRORS=1
UPDATE_MIRRORS=0
MIRRORS_MODE=0

#MAIL-ON-WARNING=root
#MAIL_CMD=mail -s "[rkhunter] Warnings found for ${HOST_NAME}"

TMPDIR=/var/lib/rkhunter/tmp
DBDIR=/var/lib/rkhunter/db
SCRIPTDIR=/usr/share/rkhunter/scripts

UPDATE_LANG="en"

LOGFILE=/var/log/rkhunter.log
#APPEND_LOG=0
COPY_LOG_ON_ERROR=1

USE_SYSLOG=authpriv.warning

#COLOR_SET2=0

AUTO_X_DETECT=1

#WHITELISTED_IS_WHITE=0

#ALLOW_SSH_ROOT_USER=no
#ALLOW_SSH_PROT_V1=0
#SSH_CONFIG_DIR=/etc/ssh

ENABLE_TESTS=all
DISABLE_TESTS=suspscan hidden_procs deleted_files packet_cap_apps apps

HASH_CMD=sha256sum

SCRIPTWHITELIST=/bin/egrep
SCRIPTWHITELIST=/bin/fgrep
SCRIPTWHITELIST=/bin/which
SCRIPTWHITELIST=/usr/bin/ldd
#SCRIPTWHITELIST=/usr/bin/lwp-request
SCRIPTWHITELIST=/usr/sbin/adduser
#SCRIPTWHITELIST=/usr/sbin/prelink
#SCRIPTWHITELIST=/usr/sbin/unhide.rb

#IMMUTWHITELIST=/sbin/ifdown
#IMMUTABLE_SET=0

#ALLOWHIDDENDIR=/etc/.java
ALLOWHIDDENDIR=/etc/.git
#ALLOWHIDDENDIR=/dev/.lxc
ALLOWHIDDENFILE=/etc/.etckeeper

WEB_CMD=curl

#UNHIDE_TESTS=sys
#UNHIDETCP_OPTS=""
DISABLE_UNHIDE=1

INSTALLDIR=/usr
" > /etc/rkhunter.conf
