#!/bin/bash

read -p "Do you want to delete and recreate? [ Y: delete and create / N: create ]" -n 1 -r
echo    # (optional) move to a new line

ODOO_CONF=config/odoo.conf
ODOO_CONF_TEMP=odoo.conf
FOLDERS=(backups config extra-addons filestore themes)

if [ -f "$ODOO_CONF" ]; then
    mv $ODOO_CONF $ODOO_CONF_TEMP
fi

for folder in ${FOLDERS[@]}; do

    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        if [ -d $folder ]; then
            rm -rf $folder
        fi
    fi

    if [ ! -d $folder ]; then
        mkdir $folder
    fi

done

if [ -f "$ODOO_CONF_TEMP" ]; then
    mv $ODOO_CONF_TEMP $ODOO_CONF
fi
