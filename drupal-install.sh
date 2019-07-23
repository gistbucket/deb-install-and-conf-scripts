# in public_html as user

# if hestia/vesta
# apt install -y php7.3-sqlite

# https://www.drupal.org/project/lightning
composer self-update
composer create-project acquia/lightning-project .
composer quick-start
composer install
