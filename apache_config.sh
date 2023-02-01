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
