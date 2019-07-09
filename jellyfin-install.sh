apt install -y apt-transport-https

wget -O - https://repo.jellyfin.org/debian/jellyfin_team.gpg.key | apt-key add -
echo "deb [arch=$( dpkg --print-architecture )] https://repo.jellyfin.org/debian $( lsb_release -c -s ) main" | tee /etc/apt/sources.list.d/jellyfin.list

apt update
apt install -y jellyfin
