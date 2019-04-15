sudo apt install -y apt-listchanges unattended-upgrades

sudo sed 's|//      "o=Debian,n=jessie,l=Debian-Security";|      "o=Debian,n=jessie,l=Debian-Security";|g' -i /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed 's|//Unattended-Upgrade::MinimalSteps "true";|Unattended-Upgrade::MinimalSteps "true";|g' -i /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed 's|//Unattended-Upgrade::Mail "root";|Unattended-Upgrade::Mail "root";|g' -i /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed 's|//Acquire::http::Dl-Limit "70";|Acquire::http::Dl-Limit "70";|g' -i /etc/apt/apt.conf.d/50unattended-upgrades
sudo sed 's|// Unattended-Upgrade::SyslogEnable "false";|Unattended-Upgrade::SyslogEnable "true";|g' -i /etc/apt/apt.conf.d/50unattended-upgrades

echo -e 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";' sudo tee /etc/apt/apt.conf.d/20auto-upgrades

echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | sudo debconf-set-selections
sudo dpkg-reconfigure -f noninteractive unattended-upgrades

sudo sed 's|which=.*|which=both|g' -i /etc/apt/listchanges.conf
