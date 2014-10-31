# base packages
yum update -y

# apache, PHP and MySQL
yum groupinstall -y "Web Server" "MySQL Database" "PHP Support"
yum install -y php-mysql

# start httpd
service httpd start
chkconfig httpd on

# change permissions of www directory
www='/var/www'
groupadd www
usermod -a -G www ec2-user
chown -R root:www /var/www
chmod 2775 $www
find $www -type d -exec chmod 2775 {} +
find $www -type f -exec chmod 0664 {} +

# configure mysql
service mysqld start
chkconfig mysqld on

mysqladmin -u root password "photoapp"
mysql -u root -p'photoapp' -e "CREATE USER photoapp@localhost IDENTIFIED BY 'photoapp'; 
create database photoapp;
grant all privileges on photoapp.* to photoapp@localhost;
flush privileges;
"
mysql -u photoapp -p'photoapp' photoapp -e 'CREATE TABLE photos ( 
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    url VARCHAR(255) NOT NULL,
    caption VARCHAR(255),
    PRIMARY KEY (id)
  )'

curl -s https://getcomposer.org/installer | php
php composer.phar install
mv db-connect.php $www
rm -rf $www/html
mv html/ $www/html
mv src/ $www/src
mv vendor/ $www/vendor
