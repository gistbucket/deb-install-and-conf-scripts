#ref: https://github.com/nodesource/distributions/issues/938
nodeVS=14

apt install -y curl software-properties-common
curl -sL https://node.melroy.org/deb/setup_$nodeVS.x | bash -
apt install -y nodejs
