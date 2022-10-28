#!/bin/bash
DOCKER_BUILDKIT=1 \
docker build \
--secret id=ENTERPRISE_TOKEN,src=../../github_token/token.txt \
--progress=plain \
-t izotecarlitos/odoo_ee:16.0 \
.
