#!/bin/bash

## EXEC: curl -L https://git.io/fjvsm|bash

tdnf install -y gawk photon-upgrade

yes|photon-upgrade.sh

reboot
