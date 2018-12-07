#!/bin/bash
#mount volume src into /opt/odoo/server 
# Dockerfile run CMD to run odoo when the container is init


docker run --rm -v /var/lib/jenkins/repos/odoo-8-docker/src:/opt/odoo/server/ -it -p 1331:8069 yavinenana/u16odoo8deb
