# ref: https://www.youtube.com/watch?v=LXJn2xjUFvc

bpVERSION=12_0_1
bpUSER=botpress
bpDIR=/opt/$bpUSER

[[ -z $(grep -qa container=lxc /proc/1/environ) ]] && \
wget -P /tmp https://raw.githubusercontent.com/JDmnT/Debian/master/lxc-client-init.sh
bash /tmp/lxc-client-init.sh

apt install -y unzip

useradd -md $bpDIR -s /bin/bash $bpUSER

wget -P /tmp https://s3.amazonaws.com/botpress-binaries/botpress-v$bpVERSION-linux-x64.zip
unzip /tmp/botpress-v$bpVERSION-linux-x64.zip -d $bpDIR/

chown -R $bpUSER:$bpUSER $bpDIR/.

sudo -iu $bpUSER $bpDIR/bp
