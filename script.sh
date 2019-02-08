#!/bin/bash
echo "########### Update packages ###########"

apt-get update && apt-get upgrade -y
apt-get install -y auditd wget vim zip unzip unrar rsync debconf-utils

echo "########### Install and configure latest version of JAVA ###########"

apt-get install -y python-software-properties software-properties-common
add-apt-repository -y ppa:webupd8team/java
apt-get update
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | debconf-set-selections
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 seen true" | debconf-set-selections
apt-get install -y oracle-java8-installer
apt-get install -y oracle-java8-set-default

cat > /etc/profile.d/java.sh << EOF
#!/bin/bash
JAVA_HOME=/usr/lib/jvm/java-8-oracle/
PATH=$JAVA_HOME/bin:$PATH
export PATH JAVA_HOME
export CLASSPATH=.
EOF

chmod +x /etc/profile.d/java.sh
source /etc/profile.d/java.sh
echo $JAVA_HOME

echo "########### Install and configure latest version of PYTHON ###########"

apt-get install -y software-properties-common
add-apt-repository -y ppa:deadsnakes/ppa
apt-get update
apt-get install -y python3
python3 --version

echo "########### Install and configure latest version of MySQL ###########"

echo mysql-server-5.5 mysql-server/root_password password root#123 | debconf-set-selections
echo mysql-server-5.5 mysql-server/root_password_again password root#123 | debconf-set-selections
apt-get install -y -q mysql-server-5.7 mysql-server-core-5.7

cat >> /etc/mysql/my.cnf <<EOF
# The MySQL server
[mysqld]
# The maximum size of the binary payload the server can handle
max_allowed_packet=8M
#max_allowed_packet = 134217728;

# By default innodb engine use one file for all databases and tables. We recommend changing this to one file per table.
# NOTE: This will take effect only if Artifactory tables are not created yet! Need to be set and MySQL restarted before starting Artifactory for the first time.
innodb_file_per_table
  
# Theses are tuning parameters that can be set to control and increase the memory buffer sizes.
innodb_buffer_pool_size=1536M
tmp_table_size=512M
max_heap_table_size=512M
  
# Theses control the innodb log files size and can be changed only when MySQL is down and MySQL will not start if there are some innodb log files left in the datadir.
# So, changing theses means removing the old innodb log files before start.
innodb_log_file_size=256M
innodb_log_buffer_size=4M
EOF

service mysql restart

mysql -uroot -proot#123 <<MYSQL_SCRIPT
CREATE DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;
GRANT ALL on zabbix.* TO 'zabbix'@'localhost' IDENTIFIED BY 'sfv2d3vAdM1nd3V321';
FLUSH PRIVILEGES;
MYSQL_SCRIPT
echo "MySQL user created."