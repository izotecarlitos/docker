#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No especifico el nombre del modulo. Intente nuevamente."
    exit 1
fi

if [ "$#" -ne 1 ]; then
    echo "Solo debe especificar el nombre de su modulo. Intente nuevamente."
    exit 1
fi

ADDONSPATH=/mnt/extra-addons

odoo scaffold $1 $ADDONSPATH
