sudo apt install -y curl

# Codium
wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/etc/apt/trusted.gpg.d/vscodium.gpg
echo 'deb https://paulcarroty.gitlab.io/vscodium-deb-rpm-repo/debs/ vscodium main' | sudo tee --append /etc/apt/sources.list.d/vscodium.list

# Syncthing
curl -s https://syncthing.net/release-key.txt | sudo apt-key add -
echo "deb https://apt.syncthing.net/ syncthing stable" | sudo tee /etc/apt/sources.list.d/syncthing.list

# Brave
curl -s https://brave-browser-apt-release.s3.brave.com/brave-core.asc | sudo apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
sudo sh -c 'echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com stable main" >> /etc/apt/sources.list.d/brave.list'

# Handbrake
sudo add-apt-repository -y ppa:stebbins/handbrake-releases

# Inkscape
sudo add-apt-repository -y ppa:inkscape.dev/stable 

# LibreOffice
sudo add-apt-repository -y ppa:libreoffice/ppa 

# OpenShot
sudo add-apt-repository -y ppa:openshot.developers/ppa

sudo apt update
sudo apt install -y brave-browser codium handbrake syncthing openshot-qt
