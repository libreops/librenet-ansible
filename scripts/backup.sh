#!/usr/bin/env bash
set -e

DATE=$(date +%F-%s)
DEST="/var/backup/diaspora"
LOGFILE="${DEST}/backup.log"
TARFILE="${DEST}/diaspora-${DATE}.tar.gz"
SQLFILE="${DEST}/diaspora-${DATE}.psql"
UPLOADSDIR="/var/www/diaspora/public/uploads"
PROSODYDIR="/var/lib/prosody"

# Make sure backup dir exits
[ ! -d "$DEST/latest" ] && mkdir -p "$DEST/latest"

# Dump Diaspora's postgres database.
# You must have /home/diaspora/.pgpass properly configured.
sudo -u diaspora -H pg_dump diaspora_production -f $SQLFILE

# Tar everything up and then gunzip it.
tar zcf $TARFILE $UPLOADSDIR $PROSODYDIR $SQLFILE

# If backup completed successfully, remove the SQL dump.
[ $? -eq 0 ] && rm $SQLFILE

# Keep a simple backup log with size name and md5sum.
echo -e "$(du -sh $TARFILE)\t$(md5sum $TARFILE | awk '{print $1}')" >> $LOGFILE

# Remove tars in `latest/` dir.
rm -rf ${DEST}/latest/*tar.gz

# Copy tar backup to `latest/` dir. Hack to download latest backup via ansible.
#cp $TARFILE ${DEST}/latest/
