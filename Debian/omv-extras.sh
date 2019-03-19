#!/bin/bash

## fix the weakref.py error
# ref: https://forum.openmediavault.org/index.php/Thread/26130-update-finished-with-errors/?postID=196287&highlight=WeakValueDictionary#post196287
wget -O /usr/lib/python3.5/weakref.py https://raw.githubusercontent.com/python/cpython/9cd7e17640a49635d1c1f8c2989578a8fc2c1de6/Lib/weakref.py

## install extras
wget -O - http://omv-extras.org/install | bash
