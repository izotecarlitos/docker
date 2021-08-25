#!/bin/sh

echo 'Type the name of the customer (without spaces or special characters. Dash - or underscore _ are accepted): ' 
read -r CUSTOMER_PROJECT_ID
CUSTOMER_PROJECT_HOME=~/projects/customers/$CUSTOMER_PROJECT_ID/
CUSTOMER_PROJECT_HOME_IDEA="$CUSTOMER_PROJECT_HOME"idea/
ODOO_SOURCE_HOME=~/projects/odoo_latest_src/

if [ -d "$CUSTOMER_PROJECT_HOME" ]; then
    echo "The directory $CUSTOMER_PROJECT_HOME exists. Please use a different one."
    exit 1
else
    echo 'Will you develop for the Enterprise Edition [y/n]? ' 
    read -r IS_ENTERPRISE
    echo 'Which Odoo Version do you want to develop for [12, 13, 14]? ' 
    read -r ODOO_VERSION
    echo 'Which port on the host will be mapped to 8069 in the odoo-container? ' 
    read -r ODOO_PORT
    echo 'Which port on the host will be mapped to 80 in the pgadmin container? ' 
    read -r PGADMIN_PORT
    echo 'Which port on the host will be mapped to 5432 in the postgres container? ' 
    read -r POSTGRES_PORT
    echo 'Which port on the host will be mapped to 8080 in the mail container? (Do not use 9000 as it will be used by Portainer)' 
    read -r MAIL_PORT

    printf '\nCreating %s \n' "$CUSTOMER_PROJECT_HOME"
    mkdir -p "$CUSTOMER_PROJECT_HOME"

    printf 'Copying project structure\n'
    cp -a ../customer-project-folder/. "$CUSTOMER_PROJECT_HOME"
    mv "$CUSTOMER_PROJECT_HOME"gitignore "$CUSTOMER_PROJECT_HOME".gitignore

    printf 'Configuring files and folders\n'
    sed -i "s|ODOO_VERSION|$ODOO_VERSION|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml        
    sed -i "s|ODOO_PORT|$ODOO_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
    sed -i "s|POSTGRES_PORT|$POSTGRES_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
    sed -i "s|PGADMIN_PORT|$PGADMIN_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
    sed -i "s|MAIL_PORT|$MAIL_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml

    export FOLDERS="backups extra-addons filestore"

    for folder in $FOLDERS; do
        mkdir -p "$CUSTOMER_PROJECT_HOME/$folder"
    done

    DEV_MACHINE_IP=$(hostname -I | awk '{print $1}')
    printf 'Your PyCharm will be setup with this IP: %s. You can change it at anytime. \n' "$DEV_MACHINE_IP"

    case "$IS_ENTERPRISE" in
        [yY][eE][sS]|[yY]) 
            printf 'Setup done for Enterprise Edition. \n'
            ;;
        *)
            sed -i '/enterprise/d' "$CUSTOMER_PROJECT_HOME_IDEA"CUSTOMER_PROJECT_ID.iml "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml "$CUSTOMER_PROJECT_HOME"docker-compose.yml
            printf 'Setup done for Community Edition. \n'
            ;;
    esac

    sed -i "s|ODOO_VERSION|$ODOO_VERSION|g" "$CUSTOMER_PROJECT_HOME_IDEA"CUSTOMER_PROJECT_ID.iml
    mv "$CUSTOMER_PROJECT_HOME_IDEA"CUSTOMER_PROJECT_ID.iml "$CUSTOMER_PROJECT_HOME_IDEA""$CUSTOMER_PROJECT_ID".iml

    mv "$CUSTOMER_PROJECT_HOME_IDEA"gitignore "$CUSTOMER_PROJECT_HOME_IDEA".gitignore

    sed -i "s|CUSTOMER_PROJECT_ID|$CUSTOMER_PROJECT_ID|g" "$CUSTOMER_PROJECT_HOME_IDEA"modules.xml
    
    sed -i "s|CUSTOMER_PROJECT_ID|$CUSTOMER_PROJECT_ID|g" "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml
    sed -i "s|CUSTOMER_PROJECT_HOME|$CUSTOMER_PROJECT_HOME|g" "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml
    sed -i "s|DEV_MACHINE_IP|$DEV_MACHINE_IP|g" "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml
    sed -i "s|ODOO_VERSION|$ODOO_VERSION|g" "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml
    sed -i "s|ODOO_SOURCE_HOME|$ODOO_SOURCE_HOME|g" "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml
    
    mv "$CUSTOMER_PROJECT_HOME_IDEA" "$CUSTOMER_PROJECT_HOME".idea/

    printf 'Success! Project %s has been created at %s\n' "$CUSTOMER_PROJECT_ID" "$CUSTOMER_PROJECT_HOME"
fi
