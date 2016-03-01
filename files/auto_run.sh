#!/bin/sh
service httpd start
service mysqld start
/usr/sbin/sshd -D
