#!/bin/bash

tdnf install -y gawk photon-upgrade

yes|photon-upgrade.sh

reboot
