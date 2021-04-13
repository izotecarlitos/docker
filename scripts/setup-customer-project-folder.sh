#!/bin/sh

read -p 'Type the name of the customer (without spaces or special characters. Dash - or underscore _ are accepted): ' CUSTOMER_PROJECT_ID
CUSTOMER_PROJECT_HOME=~/projects/customers/$CUSTOMER_PROJECT_ID/
CUSTOMER_PROJECT_HOME_IDEA="$CUSTOMER_PROJECT_HOME"idea/
ODOO_SOURCE_HOME=~/projects/odoo_latest_src/

if [ -d $CUSTOMER_PROJECT_HOME ] 
    then
        echo "The directory $CUSTOMER_PROJECT_HOME exists. Please use a different one."
        exit 1
    else
        read -p 'Will you develop for the Enterprise Edition [y/n]? ' IS_ENTERPRISE
        read -p 'Which Odoo Version do you want to develop for [12, 13, 14]? ' ODOO_VERSION
        read -p 'Which port on the host will be mapped to 8069 in the odoo-container? ' ODOO_PORT
        read -p 'Which port on the host will be mapped to 80 in the pgadmin container? ' PGADMIN_PORT
        read -p 'Which port on the host will be mapped to 5432 in the postgres container? ' POSTGRES_PORT

        echo "\nCreating $CUSTOMER_PROJECT_HOME\n"
        mkdir -p $CUSTOMER_PROJECT_HOME

        echo "Copying project structure\n"
        cp -a ../customer-project-folder/. "$CUSTOMER_PROJECT_HOME"

        echo "Configuring files and folders\n"
        sed -i '' "s|ODOO_VERSION|$ODOO_VERSION|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
        sed -i '' "s|ODOO_PORT|$ODOO_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
        sed -i '' "s|POSTGRES_PORT|$POSTGRES_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml
        sed -i '' "s|PGADMIN_PORT|$PGADMIN_PORT|g" "$CUSTOMER_PROJECT_HOME"docker-compose.yml

        FOLDERS=(backups extra-addons filestore)

        for folder in ${FOLDERS[@]}; do
            mkdir -p "$CUSTOMER_PROJECT_HOME/$folder"
        done

        DEV_MACHINE_IP=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0.1')
        echo "Your PyCharm will be setup with this IP: $DEV_MACHINE_IP. You can change it at anytime. \n"

        case "$IS_ENTERPRISE" in
            [yY][eE][sS]|[yY]) 
                echo "Setup done for Enterprise Edition. \n"
                ;;
            *)
                sed -i '' '/enterprise/d' "$CUSTOMER_PROJECT_HOME_IDEA"CUSTOMER_PROJECT_ID.iml "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml "$CUSTOMER_PROJECT_HOME"docker-compose.yml
                echo "Setup done for Community Edition. \n"
                ;;
        esac

        sed -i '' "s|ODOO_VERSION|$ODOO_VERSION|g" "$CUSTOMER_PROJECT_HOME_IDEA"CUSTOMER_PROJECT_ID.iml
        mv "$CUSTOMER_PROJECT_HOME_IDEA"CUSTOMER_PROJECT_ID.iml "$CUSTOMER_PROJECT_HOME_IDEA""$CUSTOMER_PROJECT_ID".iml

        mv "$CUSTOMER_PROJECT_HOME_IDEA"gitignore "$CUSTOMER_PROJECT_HOME_IDEA".gitignore

        sed -i '' "s|CUSTOMER_PROJECT_ID|$CUSTOMER_PROJECT_ID|g" "$CUSTOMER_PROJECT_HOME_IDEA"modules.xml
        
        sed -i '' "s|CUSTOMER_PROJECT_ID|$CUSTOMER_PROJECT_ID|g" "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml
        sed -i '' "s|CUSTOMER_PROJECT_HOME|$CUSTOMER_PROJECT_HOME|g" "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml
        sed -i '' "s|DEV_MACHINE_IP|$DEV_MACHINE_IP|g" "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml
        sed -i '' "s|ODOO_VERSION|$ODOO_VERSION|g" "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml
        sed -i '' "s|ODOO_SOURCE_HOME|$ODOO_SOURCE_HOME|g" "$CUSTOMER_PROJECT_HOME_IDEA"workspace.xml
        
        mv $CUSTOMER_PROJECT_HOME_IDEA "$CUSTOMER_PROJECT_HOME".idea/

        echo "Success! Project $CUSTOMER_PROJECT_ID has been created at $CUSTOMER_PROJECT_HOME\n"
fi
