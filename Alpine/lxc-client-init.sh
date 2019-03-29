apk add --no-cache \
  bash bzip2 \
  ca-certificates coreutils curl \
  shadow \
  tar tzdata \
  unzip \
  xz \
  wget

usermod -s /bin/bash root

groupmod -g 1000 users
useradd -Ng 1000 -mu 1000 -s /bin/bash rescue
cp -r /root/.ssh /home/rescue/
chown -R rescue:users /home/rescue/.ssh
