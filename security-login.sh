sed 's|^PASS_MIN_DAYS.*|PASS_MIN_DAYS 7|g' -i /etc/login.defs
sed 's|^PASS_MAX_DAYS.*|PASS_MAX_DAYS 180|g' -i /etc/login.defs
