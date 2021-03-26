#!/bin/bash

ODOO_MOUNT=/mnt/community/
EMPTY_FOLDER=/var/lib/odoo/empty/

mkdir -p $EMPTY_FOLDER

rsync -a --delete --info=progress2 $EMPTY_FOLDER $ODOO_MOUNT

rm -rf $EMPTY_FOLDER
