[ "$(grep LC_ALL /etc/bash.bashrc)" ] || echo -e '
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANGUAGE="en_US:en"
export LANG="en_US.UTF-8"
export LC_ALL="C"
' >> /etc/bash.bashrc

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
export LANGUAGE=en_US:en
export LANG=en_US.UTF-8
export LC_ALL=C
locale-gen en_US.UTF-8

apt update

apt-get remove -y \
  containerd \
  docker docker-engine docker.io \
  runc

apt-get install -y \
  apt-transport-https \
  ca-certificates curl \
  gnupg2 \
  software-properties-common \
  wget

curl -fsSL https://download.docker.com/linux/debian/gpg | \
  apt-key add -

# if Ubuntu == $(lsb_release -i|cut -d\: -f2)
# else OS= :-debian
#echo "deb [arch=amd64] https://download.docker.com/linux/${OS} $(lsb_release -cs) stable" | \
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | \
  tee /etc/apt/sources.list.d/docker.list

apt update

apt-get install -y \
  containerd.io \
  docker-ce docker-ce-cli

apt remove --purge -y \
  aufs*
