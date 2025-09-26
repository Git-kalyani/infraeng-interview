#!/bin/bash

# Update the package manager
sudo yum update -y

# Install Nginx
sudo amazon-linux-extras install nginx1 -y

# Start Nginx service
sudo systemctl start nginx

# Enable Nginx to start on boot
sudo systemctl enable nginx

# Allow Nginx through the firewall
sudo iptables -I INPUT -p tcp --dport 80 -j ACCEPT
sudo service iptables save
sudo service iptables restart