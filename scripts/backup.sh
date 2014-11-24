#!/usr/bin/env bash

_date=$(date +%F-%s)

mysqldump -uroot -p diaspora_production > /var/backup/diaspora-$_date.sql

tar zcf /var/backup/diaspora-$_date.tar.gz \
        /var/www/diaspora/public/uploads \
        /var/backup/diaspora-$_date.sql

if [ -f /var/backup/diaspora-$_date.tar.gz ]
  rm /var/backup/diaspora-$_date.sql
fi
