SOURCE=
TARGET=

#    -h: human readable numbers
#    -v: verbose
#    -r: recurse into directories
#    -P: --partial (keep partially transferred files) +
#        --progress (show progress during transfer)
#    -t: preserve modification times

rsync -hPrtv $SOURCE $TARGET
