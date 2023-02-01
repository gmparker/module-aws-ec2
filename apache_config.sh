#! /bin/bash
#install web server
sudo yum -y update
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html

#install kong api gateway
curl -Lo kong-enterprise-edition-3.0.1.0.aws.amd64.rpm "https://download.konghq.com/gateway-3.x-amazonlinux-2/Packages/k/kong-enterprise-edition-3.0.1.0.aws.amd64.rpm"
sudo yum install kong-enterprise-edition-3.0.1.0.aws.amd64.rpm -y

#install postgreSQL
sudo amazon-linux-extras install postgresql14 -y
sudo yum install postgresql postgresql-server -y
sudo /usr/bin/postgresql-setup --initdb
sudo systemctl enable postgresql.service
sudo systemctl start postgresql

#configure postgreSQL
sudo su - postgres
psql

CREATE USER kong WITH PASSWORD 'P@ssw0rd!'; 
CREATE DATABASE kong OWNER kong;

exit
exit

#copy kong.conf.default file
sudo cp /etc/kong/kong.conf.default /etc/kong/kong2.conf

#create kong.conf file
echo "admin_listen = *:8001 reuseport backlog=16384, *:8444 http2 ssl reuseport backlog=16384" | sudo tee -a /etc/kong/kong.conf
echo "database = postgres" | sudo tee -a /etc/kong/kong.conf
echo "pg_host = 127.0.0.1" | sudo tee -a /etc/kong/kong.conf
echo "pg_port = 5432" | sudo tee -a /etc/kong/kong.conf
echo "pg_timeout = 5000" | sudo tee -a /etc/kong/kong.conf
echo "pg_user = kong" | sudo tee -a /etc/kong/kong.conf
echo 'pg_password = P@ssw0rd!' | sudo tee -a /etc/kong/kong.conf
echo "pg_database = kong" | sudo tee -a /etc/kong/kong.conf


#copy conf file then rm
sudo cp /var/lib/pgsql/data/pg_hba.conf /var/lib/pgsql/data/pg_hba.conf.bak
sudo rm /var/lib/pgsql/data/pg_hba.conf

echo "local   all             postgres                                peer" | sudo tee -a /var/lib/pgsql/data/pg_hba.conf
echo "local   all             all                                     peer" | sudo tee -a /var/lib/pgsql/data/pg_hba.conf
echo "host    all             all             127.0.0.1/32            md5" | sudo tee -a /var/lib/pgsql/data/pg_hba.conf


#Restart postgresql
sudo systemctl restart postgresql

# Run kong migrations bootstrap
sudo /usr/local/bin/kong migrations bootstrap -c /etc/kong/kong.conf

# Start kong
sudo /usr/local/bin/kong start -c /etc/kong/kong.conf

