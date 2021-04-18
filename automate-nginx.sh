#!/bin/bash

apt-get update -y && apt-get upgrade -y
apt-get install -y nginx
echo "Olá - TREINAMENTO MICROSOFT AZURE !!!" $HOSTNAME "!" | sudo tee -a /var/www/html/index.html
