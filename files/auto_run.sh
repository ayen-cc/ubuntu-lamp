#!/bin/sh
source /etc/rc.local
service httpd start
service mysqld start
/usr/sbin/sshd -D
