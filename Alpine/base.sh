apk add --no-cache --update \
  bash bzip2 \
  ca-certificates coreutils curl \
  git \
  nano  \
  shadow \
  tar tzdata \
  unzip \
  xz \
  wget

usermod -s /bin/bash root

groupmod -g 1000 users
useradd -Ng 1000 -mu 1000 -s /bin/bash rescue
mv /root/.ssh /home/rescue/
chown -R rescue:users /home/rescue/.ssh
