#!/bin/bash

# Use this script to install Cloudera Manager 6.3 on a clean system
# Follow the Cloudera Manager GUI for creating a CDH cluster


# Configure a local Repository for Cloudera Manager and CDH

echo "[cloudera-manager]
name = Cloudera Manager, Version
baseurl = http://c902mnx09/repos/jenkins/BDA_CSTL/GA/CDH_6.3/cloudera-manager/
gpgcheck = 0" > /etc/yum.repos.d/cloudera-manager.repo

yum clean all
yum makecache

#echo "[cloudera-cdh]
#name = Cloudera CDH, Version
#baseurl = http://server/repos/jenkins/BDA_CSTL/GA/CDH_6.3/CDH-6.3.0/
#gpgcheck = 1" > /etc/yum.repos.d/cloudera-cdh.repo

# Setting up MySql repository
#echo "[mysql56-community]
#name=MySQL 5.6 Community Server
#baseurl=http://server/repos/repo.mysql.com/yum/mysql-5.6-community/el/7/x86_64
#enabled=1
#:gpgcheck=0" > /etc/yum.repos.d/mysql-community.repo


# Setting up the pre-requisites

sudo service iptables stop

echo 0 | sudo tee /selinux/enforce > /dev/null

sudo yum -y install ntp

sudo chkconfig ntpd on

sudo ntpdate "${ntp_server}"

sudo /etc/init.d/ntpd start

sudo systemctl disable firewalld
sudo systemctl stop firewalld


# Install Java
  sudo yum install oracle-j2sdk1.8

# Install Cloudera Manager Server
  sudo yum install cloudera-manager-daemons cloudera-manager-agent cloudera-manager-server

# Configuring and Starting the MariaDB Server

  sudo yum install mariadb-server -y
  systemctl stop mariadb

echo "[mysqld]
datadir=/var/lib/mysql
socket=/var/lib/mysql/mysql.sock
transaction-isolation = READ-COMMITTED
# Disabling symbolic-links is recommended to prevent assorted security risks;
# to do so, uncomment this line:
symbolic-links = 0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd

key_buffer = 16M
key_buffer_size = 32M
max_allowed_packet = 32M
thread_stack = 256K
thread_cache_size = 64
query_cache_limit = 8M
query_cache_size = 64M
query_cache_type = 1

max_connections = 550
#expire_logs_days = 10
#max_binlog_size = 100M

#log_bin should be on a disk with enough free space.
#Replace '/var/lib/mysql/mysql_binary_log' with an appropriate path for your
#system and chown the specified folder to the mysql user.
log_bin=/var/lib/mysql/mysql_binary_log

#In later versions of MariaDB, if you enable the binary log and do not set
#a server_id, MariaDB will not start. The server_id must be unique within
#the replicating group.
server_id=1

binlog_format = mixed

read_buffer_size = 2M
read_rnd_buffer_size = 16M
sort_buffer_size = 8M
join_buffer_size = 8M

# InnoDB settings
innodb_file_per_table = 1
innodb_flush_log_at_trx_commit  = 2
innodb_log_buffer_size = 64M
innodb_buffer_pool_size = 4G
innodb_thread_concurrency = 8
innodb_flush_method = O_DIRECT
innodb_log_file_size = 512M

[mysqld_safe]
log-error=/var/log/mariadb/mariadb.log
pid-file=/var/run/mariadb/mariadb.pid

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d" > /etc/my.cnf

sudo systemctl enable mariadb
sudo systemctl start mariadb

# More details to be added here
echo -e '\e[1mProvide the input as follows:\e[22m'
echo "
Enter current password for root (enter for none): Enter
Set root password? [Y/n] Y
New password: admin
Re-enter new password: admin
Remove anonymous users? [Y/n] Y
Disallow root login remotely? [Y/n] N
Remove test database and access to it [Y/n] Y
Reload privilege tables now? [Y/n] Y"

# Automating the input that is provided here
sudo /usr/bin/mysql_secure_installation <<EOF

Y
admin
admin
Y
Y
Y
Y
EOF



# Setting up MySQL JDBC driver for MariaDB 

# wget https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.46.tar.gz
# Setting up MySql repository

echo "[mysql56-community]
name=MySQL 5.6 Community Server
baseurl=http://server/repos/repo.mysql.com/yum/mysql-5.6-community/el/7/x86_64
enabled=1
gpgcheck=0" > /etc/yum.repos.d/mysql-community.repo

# Setting up MySQL JDBC driver for MariaDB

cd /root
yum install mysql-connector-java
tar zxvf mysql-connector-java-5.1.46.tar.gz
sudo mkdir -p /usr/share/java/
cd mysql-connector-java-5.1.46
sudo cp mysql-connector-java-5.1.46-bin.jar /usr/share/java/mysql-connector-java.jar


#  Creating Databases for Cloudera Software

mysql -u root -p"admin" --execute="CREATE DATABASE scm DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u root -p"admin" --execute="GRANT ALL ON scm.* TO 'scm'@'%' IDENTIFIED BY 'dbpassword';"
mysql -u root -p"admin" --execute="CREATE DATABASE amon DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u root -p"admin" --execute="GRANT ALL ON amon.* TO 'amon'@'%' IDENTIFIED BY 'dbpassword';"
mysql -u root -p"admin" --execute="CREATE DATABASE rman DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u root -p"admin" --execute="GRANT ALL ON rman.* TO 'rman'@'%' IDENTIFIED BY 'dbpassword';"
mysql -u root -p"admin" --execute="CREATE DATABASE hue DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u root -p"admin" --execute="GRANT ALL ON hue.* TO 'hue'@'%' IDENTIFIED BY 'dbpassword';"
mysql -u root -p"admin" --execute="CREATE DATABASE metastore DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u root -p"admin" --execute="GRANT ALL ON metastore.* TO 'hive'@'%' IDENTIFIED BY 'dbpassword';"
mysql -u root -p"admin" --execute="CREATE DATABASE sentry DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u root -p"admin" --execute="GRANT ALL ON sentry.* TO 'sentry'@'%' IDENTIFIED BY 'dbpassword';"
mysql -u root -p"admin" --execute="CREATE DATABASE nav DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u root -p"admin" --execute="GRANT ALL ON nav.* TO 'nav'@'%' IDENTIFIED BY 'dbpassword';"
mysql -u root -p"admin" --execute="CREATE DATABASE navms DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u root -p"admin" --execute="GRANT ALL ON navms.* TO 'navms'@'%' IDENTIFIED BY 'dbpassword';"
mysql -u root -p"admin" --execute="CREATE DATABASE oozie DEFAULT CHARACTER SET utf8 DEFAULT COLLATE utf8_general_ci;"
mysql -u root -p"admin" --execute="GRANT ALL ON oozie.* TO 'oozie'@'%' IDENTIFIED BY 'dbpassword';"


# Install the Cloudera packages

sudo yum -y install cloudera-manager-daemons cloudera-manager-agent cloudera-manager-server

sudo service cloudera-scm-server start

sudo /opt/cloudera/cm/schema/scm_prepare_database.sh mysql scm scm dbpassword

# Setting up a CDH cluster
echo "[cloudera-cdh]
name = Cloudera CDH, Version
baseurl = http://server/repos/jenkins/BDA_CSTL/GA/CDH_6.3/CDH-6.3.0/
gpgcheck = 0" > /etc/yum.repos.d/cloudera-cdh.repo


sudo tail -f /var/log/cloudera-scm-server/cloudera-scm-server.log






