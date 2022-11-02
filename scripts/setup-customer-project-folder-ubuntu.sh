#!/bin/sh

echo 'Type the name of the customer-project' 
echo 'Do NOT use spaces or special characters.'
echo 'Dash - or underscore _ are accepted): ' 
read -r CUSTOMER_PROJECT_ID
CUSTOMER_PROJECT_HOME=~/projects/customers/$CUSTOMER_PROJECT_ID/
CUSTOMER_PROJECT_HOME_IDEA="$CUSTOMER_PROJECT_HOME"idea/
ODOO_SOURCE_HOME=~/projects/odoo_src/
# community= odoo; enterprise=odoo_ee
ODOO_EDITION=odoo

if [ -d "$CUSTOMER_PROJECT_HOME" ]; then
    echo "The directory $CUSTOMER_PROJECT_HOME exists. Please use a different one."
    exit 1
else
    echo 'Will you develop for the Enterprise Edition [y/n]? (default: y)' 
    read -r IS_ENTERPRISE
    IS_ENTERPRISE="${IS_ENTERPRISE:=y}"
    echo 'Which Odoo Version do you want to develop for [12, 13, 14, 15, 16]? (default: 15)' 
    read -r ODOO_VERSION
    ODOO_VERSION="${ODOO_VERSION:=15}"
    echo 'Which port on the host will be mapped to 8069 in the odoo-container? (default: 8069)' 
    read -r ODOO_PORT
    ODOO_PORT="${ODOO_PORT:=8069}"
    echo 'Which port on the host will be mapped to 80 in the DB manager container? (default: 80)' 
    read -r DBMAN_PORT
    DBMAN_PORT="${DBMAN_PORT:=80}"
    echo 'Which port on the host will be mapped to 5432 in the postgres container? (default: 5432)' 
    read -r POSTGRES_PORT
    POSTGRES_PORT="${POSTGRES_PORT:=5432}"
    echo 'Which port on the host will be mapped to 8080 in the mail container? (default: 8080)' 
    read -r MAIL_PORT
    MAIL_PORT="${MAIL_PORT:=8080}"

    printf '\nCreating %s \n' "$CUSTOMER_PROJECT_HOME"
    mkdir -p "$CUSTOMER_PROJECT_HOME"

    printf 'Copying project structure\n'
    cp -a ../customer-project-folder/. "$CUSTOMER_PROJECT_HOME"
    mv "$CUSTOMER_PROJECT_HOME"gitignore "$CUSTOMER_PROJECT_HOME".gitignore

    export FOLDERS="backups extra-addons filestore"

    printf 'Creating folders\n'
    for folder in $FOLDERS; do
        mkdir -p "$CUSTOMER_PROJECT_HOME/$folder"
    done

    DEV_MACHINE_IP=$(hostname -I | awk '{print $1}')
    printf 'Your PyCharm will be setup with this IP: %s. You can change it at anytime. \n' "$DEV_MACHINE_IP"

    case "$IS_ENTERPRISE" in
        [yY][eE][sS]|[yY]) 
            printf 'Setup done for Enterprise Edition. \n'
            ODOO_EDITION=odoo_ee
            ;;
        *)
            sed -i '/enterprise/d' "$CUSTOMER_PROJECT_HOME_IDEA"CUSTOMER_PROJECT_ID.iml "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml "$CUSTOMER_PROJECT_HOME"docker-compose.yml
            printf 'Setup done for Community Edition. \n'
            ODOO_EDITION=odoo
            ;;
    esac

    printf 'Seting up PyCharm project\n'
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

    printf 'Setting up docker-compose.yml\n'
    sed -i "s|PROJECT|$CUSTOMER_PROJECT_ID|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
    sed -i "s|ODOO_EDITION|$ODOO_EDITION|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
    sed -i "s|ODOO_VERSION|$ODOO_VERSION|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
    sed -i "s|ODOO_PORT|$ODOO_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
    sed -i "s|POSTGRES_PORT|$POSTGRES_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
    sed -i "s|DBMAN_PORT|$DBMAN_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
    sed -i "s|MAIL_PORT|$MAIL_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml

    printf 'Success! Project %s has been created at %s\n' "$CUSTOMER_PROJECT_ID" "$CUSTOMER_PROJECT_HOME"

fi
