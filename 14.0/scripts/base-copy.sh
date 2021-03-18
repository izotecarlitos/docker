#!/bin/bash

ODOO_BASE=/usr/lib/python3/dist-packages/odoo/.
ODOO_MOUNT=/mnt/community

rsync -a --delete --info=progress2 $ODOO_BASE $ODOO_MOUNT
