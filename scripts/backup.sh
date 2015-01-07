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

# Dump Diaspora's mysql database.
# You must have /root/.my.cnf properly configured.
mysqldump -uroot diaspora_production > $SQLFILE

# Tar everything up and then gunzip it. If there is no uploads folder, just
# include the database dump.
[ -d "$UPLOADSDIR" ] && \
tar zcf $TARFILE $UPLOADSDIR $SQLFILE || \
tar zcf $TARFILE $SQLFILE

# If backup completed successfully, remove the mysql dump.
[ $? -eq 0 ] && rm $SQLFILE

# Keep a simple backup log with size name and md5sum.
echo -e "$(du -sh $TARFILE)\t$(md5sum $TARFILE | awk '{print $1}')" >> $LOGFILE

# Remove everything in `latest/` dir.
rm -rf ${DEST}/latest/*tar.gz

# Copy tar backup to `latest/` dir. Hack to download latest backup via ansible.
cp $TARFILE ${DEST}/latest/
