# syntax=docker/dockerfile:1

FROM izotecarlitos/odoo:13.0
LABEL maintainer="Carlitos Melgar <carlitos.melgar@izote.net>"

# Change back to root in order to setup this image
USER root

ENV ENTERPRISE_HOME="/mnt/enterprise/"

RUN --mount=type=secret,id=ENTERPRISE_TOKEN \
curl -H "Authorization: token "$(cat /run/secrets/ENTERPRISE_TOKEN)"" \
    -H 'Accept: application/vnd.github.v4.raw' \
    --create-dirs --output \
    "$ENTERPRISE_HOME"temp/enterprise_"$ODOO_VERSION".latest.zip \
    -L https://github.com/odoo/enterprise/archive/"$ODOO_VERSION".zip \
&& unzip -q "$ENTERPRISE_HOME"temp/enterprise_"$ODOO_VERSION".latest.zip -d "$ENTERPRISE_HOME"temp \
&& rsync -a --exclude '*.zip' \
    "$ENTERPRISE_HOME"temp/enterprise-"$ODOO_VERSION"/ \
    "$ENTERPRISE_HOME" \
&& rm -rf "$ENTERPRISE_HOME"temp

# Set permissions for enterprise
RUN chown -R odoo /mnt/enterprise 

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]
