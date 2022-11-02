#!/bin/bash

echo 'Do you want to update everything [ Y / N ]?' 
read -r UPDATE_ALL 

# Global directory paths
SOURCES_HOME=~/projects/odoo_src/
COMMUNITY_HOME="$SOURCES_HOME"community/
ENTERPRISE_HOME="$SOURCES_HOME"enterprise/
STUBS_HOME="$SOURCES_HOME"odoo-stubs/

ENTERPRISE_TOKEN=~/projects/odoo-docker/github_token/token.txt

# Global script control variables
ODOO_VERSION=""
DOWNLOAD_ODOO_COMMUNITY=""
DOWNLOAD_ODOO_ENTERPRISE=""
DOWNLOAD_ODOO_STUBS="Y"
DOWNLOAD_ODOO_IMAGE="Y"

# Supported Odoo Versions
ODOO_VERSIONS=(16.0 15.0 14.0 13.0 12.0)

# Function to download Odoo Community
download_odoo_community() {
    case ${DOWNLOAD_ODOO_COMMUNITY:0:1} in
    y|Y )
        SRC_HOME="$COMMUNITY_HOME""$ODOO_VERSION/"
        echo -e "Downloading Odoo Community $ODOO_VERSION to $SRC_HOME \n"

        if [ -d "$SRC_HOME" ]; then
            rm -rf "${SRC_HOME:?}"
        fi

        curl https://nightly.odoo.com/"$ODOO_VERSION"/nightly/tgz/odoo_"$ODOO_VERSION".latest.zip \
            --create-dirs --output \
            "$SRC_HOME"temp/odoo_"$ODOO_VERSION".latest.zip
        unzip -q "$SRC_HOME"temp/odoo_"$ODOO_VERSION".latest.zip \
            -d "$SRC_HOME"temp
        rsync -a --exclude '*.zip' \
            "$SRC_HOME"temp/odoo-"$ODOO_VERSION"*/ \
            "$SRC_HOME"
        rm -rf "$SRC_HOME"temp

        echo -e "\nOdoo Community $ODOO_VERSION was downloaded \n"
    ;;
    * )
        echo -e "\nOdoo Community $ODOO_VERSION will not be downloaded \n"
    ;;
    esac
}

# Function to download Odoo Enterprise
download_odoo_enterprise() {
    case ${DOWNLOAD_ODOO_ENTERPRISE:0:1} in
    y|Y )

        if [ -f "$ENTERPRISE_TOKEN" ]; then

            token=$(<"$ENTERPRISE_TOKEN")
            SRC_HOME="$ENTERPRISE_HOME""$ODOO_VERSION/"
            echo -e "Downloading Odoo Enterprise $ODOO_VERSION to $SRC_HOME \n"

            if [ -d "$SRC_HOME" ]; then
                rm -rf "${SRC_HOME:?}"
            fi

            curl -H "Authorization: token $token" \
                -H 'Accept: application/vnd.github.v4.raw' \
                --create-dirs --output \
                "$SRC_HOME"temp/enterprise_"$ODOO_VERSION".latest.zip \
                -L https://github.com/odoo/enterprise/archive/"$ODOO_VERSION".zip
            unzip -q "$SRC_HOME"temp/enterprise_"$ODOO_VERSION".latest.zip \
                -d "$SRC_HOME"temp
            rsync -a --exclude '*.zip' \
                "$SRC_HOME"temp/enterprise-"$ODOO_VERSION"/ \
                "$SRC_HOME"
            rm -rf "$SRC_HOME"temp

            echo -e "\nOdoo Enterprise $ODOO_VERSION was downloaded \n"

        else

            echo -e "\nToken is not available or valid for Odoo Enterprise $ODOO_VERSION\n"

        fi

    ;;
    * )
        echo -e "\nOdoo Enterprise $ODOO_VERSION will not be downloaded \n"
    ;;
    esac
}

# Function to download Odoo Stubs
download_odoo_stubs() {
    case ${DOWNLOAD_ODOO_STUBS:0:1} in
    y|Y )
        echo -e "Downloading Odoo Stubs $ODOO_VERSION \n"

        SRC_HOME="$STUBS_HOME""$ODOO_VERSION/"
        echo -e "Downloading Odoo Stubs $ODOO_VERSION to $SRC_HOME \n"

        if [ -d "$SRC_HOME" ]; then
            rm -rf "${SRC_HOME:?}"
        fi

        curl https://codeload.github.com/trinhanhngoc/odoo-stubs/zip/"$ODOO_VERSION" \
            --create-dirs --output \
            "$SRC_HOME"temp/odoo-stubs.zip

        unzip -q "$SRC_HOME"temp/odoo-stubs.zip \
            -d "$SRC_HOME"temp
        rsync -a --exclude '*.zip' \
            "$SRC_HOME"temp/odoo-stubs-"$ODOO_VERSION"/ \
            "$SRC_HOME"
        rm -rf "$SRC_HOME"temp

        echo -e "\nOdoo Stubs $ODOO_VERSION was downloaded \n"
    ;;
    * )
        echo -e "\nOdoo Stubs $ODOO_VERSION will not be downloaded \n"
    ;;
    esac
}

# Function to download Docker Images about Odoo
download_odoo_image() {
    case ${DOWNLOAD_ODOO_IMAGE:0:1} in
    y|Y )
        echo -e "Downloading Odoo Images for $ODOO_VERSION \n"

        docker pull odoo:"$ODOO_VERSION"
        docker pull izotecarlitos/odoo-container:"$ODOO_VERSION"

        echo -e "\nDocker Odoo for $ODOO_VERSION were downloaded \n"
    ;;
    * )
        echo -e "\nDocker Odoo for $ODOO_VERSION will not be downloaded \n"
    ;;
    esac
}

download_odoo_stack_images() {

    echo -e "Downloading Images for Odoo Stacks \n"

    docker pull greenmail/standalone:latest
    docker pull dbeaver/cloudbeaver:latest
    docker pull postgres:12.5
    
    echo -e "\nImages for Odoo Stacks were downloaded \n"

}

# Swith statement to UPDATE ALL sources and images or state a SINGLE version
case ${UPDATE_ALL:0:1} in
    y|Y )

    # Add one line break
    echo -e "\n"

    # Set all these variables to Y
    DOWNLOAD_ODOO_COMMUNITY=Y
    DOWNLOAD_ODOO_ENTERPRISE=Y

    for odoo_version in "${ODOO_VERSIONS[@]}"; do

        ODOO_VERSION=$odoo_version
    
        download_odoo_community
        download_odoo_enterprise
        download_odoo_stubs
        #download_odoo_image

    done

    download_odoo_stack_images

    ;;
    * )
        echo -e "\nThese are the supported Odoo Versions"
        echo -e "=====================================\n"
        PS3='Please select the one you would like: '
        options=("16 Community & Enterprise" "16 Community" "16 Enterprise" \
                 "15 Community & Enterprise" "15 Community" "15 Enterprise" \
                 "14 Community & Enterprise" "14 Community" "14 Enterprise" \
                 "13 Community & Enterprise" "13 Community" "13 Enterprise" \
                 "12 Community & Enterprise" "12 Community" "12 Enterprise" \
                 Quit)
        select opt in "${options[@]}"
        do
            case $opt in
                "16 Community & Enterprise")
                    ODOO_VERSION="16.0"
                    DOWNLOAD_ODOO_COMMUNITY="Y"
                    DOWNLOAD_ODOO_ENTERPRISE="Y"
                    break
                    ;;
                "16 Community")
                    ODOO_VERSION="16.0"
                    DOWNLOAD_ODOO_COMMUNITY="Y"
                    DOWNLOAD_ODOO_ENTERPRISE="N"
                    break
                    ;;
                "16 Enterprise")
                    ODOO_VERSION="16.0"
                    DOWNLOAD_ODOO_COMMUNITY="N"
                    DOWNLOAD_ODOO_ENTERPRISE="Y"
                    break
                    ;;
                "15 Community & Enterprise")
                    ODOO_VERSION="15.0"
                    DOWNLOAD_ODOO_COMMUNITY="Y"
                    DOWNLOAD_ODOO_ENTERPRISE="Y"
                    break
                    ;;
                "15 Community")
                    ODOO_VERSION="15.0"
                    DOWNLOAD_ODOO_COMMUNITY="Y"
                    DOWNLOAD_ODOO_ENTERPRISE="N"
                    break
                    ;;
                "15 Enterprise")
                    ODOO_VERSION="15.0"
                    DOWNLOAD_ODOO_COMMUNITY="N"
                    DOWNLOAD_ODOO_ENTERPRISE="Y"
                    break
                    ;;
                "14 Community & Enterprise")
                    ODOO_VERSION="14.0"
                    DOWNLOAD_ODOO_COMMUNITY="Y"
                    DOWNLOAD_ODOO_ENTERPRISE="Y"
                    break
                    ;;
                "14 Community")
                    ODOO_VERSION="14.0"
                    DOWNLOAD_ODOO_COMMUNITY="Y"
                    DOWNLOAD_ODOO_ENTERPRISE="N"
                    break
                    ;;
                "14 Enterprise")
                    ODOO_VERSION="14.0"
                    DOWNLOAD_ODOO_COMMUNITY="N"
                    DOWNLOAD_ODOO_ENTERPRISE="Y"
                    break
                    ;;
                "13 Community & Enterprise")
                    ODOO_VERSION="13.0"
                    DOWNLOAD_ODOO_COMMUNITY="Y"
                    DOWNLOAD_ODOO_ENTERPRISE="Y"
                    break
                    ;;
                "13 Community")
                    ODOO_VERSION="13.0"
                    DOWNLOAD_ODOO_COMMUNITY="Y"
                    DOWNLOAD_ODOO_ENTERPRISE="N"
                    break
                    ;;
                "13 Enterprise")
                    ODOO_VERSION="13.0"
                    DOWNLOAD_ODOO_COMMUNITY="N"
                    DOWNLOAD_ODOO_ENTERPRISE="Y"
                    break
                    ;;
                "12 Community & Enterprise")
                    ODOO_VERSION="12.0"
                    DOWNLOAD_ODOO_COMMUNITY="Y"
                    DOWNLOAD_ODOO_ENTERPRISE="Y"
                    break
                    ;;
                "12 Community")
                    ODOO_VERSION="12.0"
                    DOWNLOAD_ODOO_COMMUNITY="Y"
                    DOWNLOAD_ODOO_ENTERPRISE="N"
                    break
                    ;;
                "12 Enterprise")
                    ODOO_VERSION="14.0"
                    DOWNLOAD_ODOO_COMMUNITY="N"
                    DOWNLOAD_ODOO_ENTERPRISE="Y"
                    ;;
                "Quit")
                    exit 
                    ;;
                *) printf 'Your selection: %s is Invalid. Please try again.\n' "$REPLY";;
            esac
        done
        # Add one line break
        echo -e "\n"

        download_odoo_community
        download_odoo_enterprise
        download_odoo_stubs
        #download_odoo_image
        download_odoo_stack_images

    ;;
esac
