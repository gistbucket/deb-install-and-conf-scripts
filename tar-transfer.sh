#!/bin/bash -eux

# The fastest way to transfert data from a machine to another one
# NOTE: in some case you want to __--remove-files__ after a successful transfer.
# Uncomment the command you want to execute

remoteUser=
remoteIP=
Directory=

## From a remote machine to the local machine

#ssh ${remoteUser}@${remoteIP} 'tar --remove-files -cf - ${Directory}' | tar -vxf - -C /
#ssh ${remoteUser}@${remoteIP} 'tar -cf - ${Directory}' | tar -vxf - -C /

## From the local machine to a remote machine

#tar --remove-files -cf - ${Directory} | ssh ${remoteUser}@${remoteIP} 'tar -vxf - -C /'
#tar -cf - ${Directory} | ssh ${remoteUser}@${remoteIP} 'tar -vxf - -C /'
