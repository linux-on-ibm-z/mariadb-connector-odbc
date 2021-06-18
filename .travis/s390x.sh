#!/bin/bash

set -x
set -e

DEBIAN_FRONTEND=noninteractive sudo apt-get update
DEBIAN_FRONTEND=noninteractive sudo apt remove -y mariadb-server mariadb-server-10.3 mariadb-server-core-10.3
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y mariadb-server unixodbc-dev git cmake gcc libssl-dev tar curl libcurl4-openssl-dev libkrb5-dev 

sudo service mysql start
sudo ln -s /var/run/mysqld/mysqld.sock /tmp/mysql.sock
sudo mysql -u root -e 'CREATE DATABASE IF NOT EXISTS test;'
sudo mysql -u root -e "USE mysql; UPDATE user SET plugin='mysql_native_password' WHERE User='root'; FLUSH PRIVILEGES;"
mysql --version

# set variables for Connector/ODBC
export TEST_DRIVER=maodbc_test
export TEST_SCHEMA=test
export TEST_DSN=maodbc_test
export TEST_UID=root
export TEST_PASSWORD=

cmake -DCMAKE_BUILD_TYPE=RelWithDebInfo -DWITH_OPENSSL=ON -DWITH_SSL=OPENSSL -DODBC_LIB_DIR=/usr/lib/s390x-linux-gnu/
cmake --build . --config RelWithDebInfo 

###################################################################################################################
# run test suite
###################################################################################################################

echo "Running tests"

cd test
export ODBCINI="$PWD/odbc.ini"
export ODBCSYSINI=$PWD

ctest -V
