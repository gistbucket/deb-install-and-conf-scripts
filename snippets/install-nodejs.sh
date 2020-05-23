#ref: https://github.com/nodesource/distributions/issues/938
nodeVS=14

apt install -y curl software-properties-common
curl -sL https://node.melroy.org/deb/setup_12.x | bash -
apt install -y nodejs
