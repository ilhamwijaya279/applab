#!/bin/bash
DATABASE_PASS='Admin123!@#'
sudo yum update -y
sudo yum install epel-release -y
sudo yum install git zip unzip -y
sudo yum install mariadb-server -y


# starting & enabling mariadb-server
sudo systemctl start mariadb
sudo systemctl enable mariadb
cd /tmp/
wget 192.168.56.1:8000/applab.zip
unzip applab.zip

sudo mysqladmin -u root password "$DATABASE_PASS"
sudo mysql -u root -p"$DATABASE_PASS" -e "UPDATE mysql.user SET Password=PASSWORD('$DATABASE_PASS') WHERE User='root'"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.user WHERE User=''"
sudo mysql -u root -p"$DATABASE_PASS" -e "DELETE FROM mysql.db WHERE Db='test' OR Db='test\_%'"
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"
sudo mysql -u root -p"$DATABASE_PASS" -e "create database users"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on users.* TO 'admin'@'localhost' identified by 'Admin123'"
sudo mysql -u root -p"$DATABASE_PASS" -e "grant all privileges on users.* TO 'admin'@'%' identified by 'Admin123'"
sudo mysql -u root -p"$DATABASE_PASS" users < /tmp/applab/tools/dump.sql
sudo mysql -u root -p"$DATABASE_PASS" -e "FLUSH PRIVILEGES"


# Restart mariadb-server
sudo systemctl restart mariadb


#starting the firewall and allowing the mariadb to access from port no. 3306
sudo systemctl start firewalld
sudo systemctl enable firewalld
sudo firewall-cmd --get-active-zones
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
sudo firewall-cmd --reload
sudo systemctl restart mariadb
