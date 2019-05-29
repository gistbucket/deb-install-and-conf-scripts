apt install -y apt-listchanges unattended-upgrades

sed 's|//      "o=Debian,n=jessie,l=Debian-Security";|      "o=Debian,n=jessie,l=Debian-Security";|g' -i /etc/apt/apt.conf.d/50unattended-upgrades
sed 's|//Unattended-Upgrade::MinimalSteps "true";|Unattended-Upgrade::MinimalSteps "true";|g' -i /etc/apt/apt.conf.d/50unattended-upgrades
sed 's|//Unattended-Upgrade::Mail "root";|Unattended-Upgrade::Mail "root";|g' -i /etc/apt/apt.conf.d/50unattended-upgrades
sed 's|//Acquire::http::Dl-Limit "70";|Acquire::http::Dl-Limit "70";|g' -i /etc/apt/apt.conf.d/50unattended-upgrades
sed 's|// Unattended-Upgrade::SyslogEnable "false";|Unattended-Upgrade::SyslogEnable "true";|g' -i /etc/apt/apt.conf.d/50unattended-upgrades

echo -e 'APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";' tee /etc/apt/apt.conf.d/20auto-upgrades

echo unattended-upgrades unattended-upgrades/enable_auto_updates boolean true | debconf-set-selections
dpkg-reconfigure -f noninteractive unattended-upgrades

sed 's|which=.*|which=both|g' -i /etc/apt/listchanges.conf
