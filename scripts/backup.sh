#!/usr/bin/env bash
set -e

DATE=$(date +%F-%s)
DEST="/var/backup"
LOGFILE="${DEST}/backup.log"
TARFILE="${DEST}/diaspora-${DATE}.tar.gz"
SQLFILE="${DEST}/diaspora-${DATE}.sql"
UPLOADSDIR="/var/www/diaspora/public/uploads"

# Make sure backup dir exits
[ ! -d "$DEST/latest" ] && mkdir -p "$DEST/latest"

mysqldump -uroot diaspora_production > $SQLFILE

[ -d "$UPLOADSDIR" ] && \
tar zcf $TARFILE $UPLOADSDIR $SQLFILE || \
tar zcf $TARFILE $SQLFILE

echo -e "$(du -sh $TARFILE)\t$(md5sum $TARFILE | awk '{print $1}')" >> $LOGFILE

[ -f $TARFILE ] && rm $SQLFILE

rm -rf ${DEST}/latest/*tar.gz

cp $TARFILE ${DEST}/latest/
