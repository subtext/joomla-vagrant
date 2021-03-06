#!/usr/bin/bash
PASSWD1=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
PASSWD2=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
yum -y --quiet install wget emacs
yum -y --quiet install epel-release
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -Uvh epel-release-latest-7*.rpm
yum -y --quiet install yum-utils
yum-config-manager --enable remi-php71
yum -y --quiet install httpd php php-mysql php-soap php-xml php-gd php-mcrypt mariadb mariadb-server unzip policycoreutils-python
cd /home/vagrant
cp /vagrant/bootstrap.mysql /vagrant/bootstrap-provision.mysql
sed -i "s/rootpassword/$PASSWD1/" /vagrant/bootstrap-provision.mysql
sed -i "s/joomlapassword/$PASSWD2/" /vagrant/bootstrap-provision.mysql
wget --quiet https://github.com/joomla/joomla-cms/releases/download/3.5.1/Joomla_3.5.1-Stable-Full_Package.zip
mv /home/vagrant/Joomla_3.5.1-Stable-Full_Package.zip /var/www/html/joomla.zip
cd /var/www/html
unzip -qq joomla.zip
chown -R apache:apache /var/www/html
chcon -R -t httpd_sys_rw_content_t /var/www/html
systemctl --quiet enable mariadb.service
systemctl --quiet start mariadb.service
systemctl --quiet enable httpd.service
systemctl --quiet start httpd.service
echo "The root mysql password is: $PASSWD1"
echo "The joomla database password is: $PASSWD2"
mysql -u root -D mysql < /vagrant/bootstrap-provision.mysql
