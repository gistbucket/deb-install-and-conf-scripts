echo -e "
[mysqld]
user=mysql
pid-file=/var/run/mysqld/mysqld.pid
socket=/var/run/mysqld/mysqld.sock
skip-networking
bind-address=127.0.0.1
port=3306
basedir=/usr
datadir=/var/lib/mysql
tmpdir=/tmp
lc-messages-dir=/usr/share/mysql
explicit_defaults_for_timestamp
log-error=/var/log/mysql/error.log

# Recommended in standard MySQL setup
sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_ALL_TABLES

# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0

local-infile=0

# http://bugs.mysql.com/bug.php?id=68514
performance_schema=OFF
max_connections=50

# https://github.com/linuxserver/docker-mariadb/blob/master/root/defaults/my.cnf
connect_timeout=5
wait_timeout=600
thread_cache_size=128
sort_buffer_size=4M
bulk_insert_buffer_size=16M
tmp_table_size=32M
max_heap_table_size=32M

myisam_recover_options=BACKUP
key_buffer_size=128M
table_open_cache=400
myisam_sort_buffer_size=512M
concurrent_insert=2
read_buffer_size=2M
read_rnd_buffer_size=1M

# https://haydenjames.io/mysql-query-cache-size-performance/
query_cache_type=1
query_cache_limit=128K
query_cache_size=64M

log_warnings=2
slow_query_log_file=/var/log/mysql/mariadb-slow.log
long_query_time=10
log_slow_verbosity=query_plan
expire_logs_days=10  
max_binlog_size=100M

innodb=on
default_storage_engine=InnoDB  
innodb_buffer_pool_size=256M
innodb_log_buffer_size=8M
innodb_file_per_table=1
innodb_open_files=400
innodb_io_capacity=400
innodb_flush_method=O_DIRECT

# on ec2, without this we get a sporadic connection drop when doing the initial migration
max_allowed_packet=32M

# https://mathiasbynens.be/notes/mysql-utf8mb4
character-set-client-handshake=FALSE
character-set-server=utf8mb4
collation-server=utf8mb4_unicode_ci

[mysqldump]
quick
quote-names
max_allowed_packet=16M
default-character-set=utf8mb4

[mysql]
default-character-set=utf8mb4

[client]
default-character-set=utf8mb4

[isamchk]
key_buffer_size=16M

[mysqld_safe]
pid-file=/var/run/mysqld/mysqld.pid
socket=/var/run/mysqld/mysqld.sock
nice=0
" >> /etc/mysql/percona-server.conf.d/mysqld.cnf

systemctl restart mysql
