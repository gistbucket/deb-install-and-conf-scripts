modprobe -r cramfs freevxfs hfs hfsplus jffs2 squashfs udf
echo -e "## lynis recommandation FILE-6430
install cramfs /bin/true
install freevxfs /bin/true
install hfs /bin/true
install hfsplus /bin/true
install jffs2 /bin/true
install squashfs /bin/true
install udf /bin/true
" > /etc/modprobe.d/blacklist_filesystem
