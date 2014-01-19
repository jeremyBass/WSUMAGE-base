#!/bin/bash
#setup the mail
debconf-set-selections <<< "postfix postfix/mailname string store.mage.dev"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Internet Site'"
sudo apt-get install -y postfix
#sudo apt-get install -y courier-pop
#sudo apt-get install -y courier-imap
sudo postconf -e "mydestination = mail.store.mage.dev, localhost.localdomain, localhost, mage.dev, store.mage.dev"
#sudo postconf -e "mynetworks = 127.0.0.0/8, 192.168.50.4/24"
sudo postconf -e "inet_interfaces = all"
sudo postconf -e "inet_protocols = all" ## make ip6 ready
sudo  /etc/init.d/postfix restart