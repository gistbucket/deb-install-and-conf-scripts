sUSER=
sDOMAIN=
WORKERS=$(cat /proc/cpuinfo | awk '/^processor/{print $3}' | wc -l)

#ref: https://asciimoo.github.io/searx/dev/install/installation.html

apt install -y git python-dev python-virtualenv python-babel uwsgi uwsgi-plugin-python

echo -e "[uwsgi]
# Who will run the code
uid = searx
gid = searx

# disable logging for privacy
disable-logging = true

# Number of workers (usually CPU count)
workers = $WORKERS

# The right granted on the created socket
chmod-socket = 666

# Plugin to use and interpretor config
single-interpreter = true
master = true
plugin = python
lazy-apps = true
enable-threads = true

# Module to import
module = searx.webapp

# Virtualenv and python path
virtualenv = /home/$sUSER/web/$sDOMAIN/public_html/searx-ve/
pythonpath = /home/$sUSER/web/$sDOMAIN/public_html/
chdir = /home/$sUSER/web/$sDOMAIN/public_html/searx/" > /etc/uwsgi/apps-available/searx.ini

cd /etc/uwsgi/apps-enabled
ln -s ../apps-available/searx.ini

#head -qn4 /home/$sUSER/conf/web/$sDOMAIN.nginx.conf > /tmp/$sDOMAIN.nginx.conf
#echo -e "
#    location / {
#            include uwsgi_params;
#            uwsgi_pass unix:/run/uwsgi/app/searx/socket;
#    }
#}" > /home/$sUSER/conf/web/$sDOMAIN.nginx.conf

#head -qn11 /home/$sUSER/conf/web/$sDOMAIN.nginx.ssl.conf > /tmp/$sDOMAIN.nginx.ssl.conf
#echo -e "
#    location / {
#            include uwsgi_params;
#            uwsgi_pass unix:/run/uwsgi/app/searx/socket;
#    }
#}" > /home/$sUSER/conf/web/$sDOMAIN.nginx.ssl.conf

cd /home/$sUSER/web/$sDOMAIN/public_html
rm -Rf /home/$sUSER/web/$sDOMAIN/public_html/*
rm -Rf /home/$USER/web/$sDOMAIN/public_html/.*
git clone https://github.com/asciimoo/searx.git .
useradd searx -d /home/$sUSER/web/$sDOMAIN/public_html
chown searx:searx -R /home/$sUSER/web/$sDOMAIN/public_html/.

sudo -u searx -i

virtualenv searx-ve
. ./searx-ve/bin/activate
./manage.sh update_packages

sed -i -e "s/ultrasecretkey/`openssl rand -hex 16`/g" searx/settings.yml
sed -i -e "s/debug : True/debug : False/g" searx/settings.yml
exit
