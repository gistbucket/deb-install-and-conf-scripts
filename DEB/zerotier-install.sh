ztNETWORKid=""

curl -s https://raw.githubusercontent.com/zerotier/ZeroTierOne/master/doc/contact%40zerotier.com.gpg | gpg --import
curl -s https://install.zerotier.com/ | gpg --output - >/tmp/zt-install.sh && bash /tmp/zt-install.sh

zerotier-cli join $ztNETWORKid
systemctl enable zerotier-one

echo "Don't forget to approve your ID: $(cut -d: -f1 /var/lib/zerotier-one/identity.secret)."
