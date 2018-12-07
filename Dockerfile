#FROM python:2.7
FROM coreapps/ubuntu16.04
MAINTAINER Yaroslab S.A.C. <@yaroslab.com>

ENV ODOO_USER=odoo
ENV BASE_HOME=/opt
ENV ODOO_HOME=/odoo/server

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
            ca-certificates \
            curl zip wget vim net-tools\
	    python-gevent python-pip python-dev libcurl4-openssl-dev python-setuptools \
	&& apt install postgresql-client -y \
        && curl -o wkhtmltox.deb -SL http://nightly.odoo.com/extra/wkhtmltox-0.12.1.2_linux-jessie-amd64.deb \
        && echo '40e8b906de658a2221b15e4e8cd82565a47d7ee8 wkhtmltox.deb' | sha1sum -c - \
        && dpkg --force-depends -i wkhtmltox.deb \
        && apt-get -y install -f --no-install-recommends \
        && apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false -o APT::AutoRemove::SuggestsImportant=false npm \
        && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

RUN groupadd -r $ODOO_USER && useradd -r -g $ODOO_USER $ODOO_USER
RUN mkdir -p $BASE_HOME$ODOO_HOME

# REQUERIMENTs
RUN pip install --upgrade pip
COPY ./requirements-merged.txt $BASE_HOME$ODOO_HOME/requirements.txt
RUN pip install -r $BASE_HOME$ODOO_HOME/requirements.txt

WORKDIR $BASE_HOME$ODOO_HOME
#ADD ./src $BASE_HOME$ODOO_HOME

#RUN set -x; \
#	curl -o $BASE_HOME$ODOO_HOME/odoo.zip https://nightly.odoo.com/8.0/nightly/src/old/odoo_8.0.20160701.zip 
#RUN unzip odoo.zip -d $BASE_HOME$ODOO_HOME/
# Copy entrypoint script and Odoo configuration file
#COPY ./openerp-server.conf /etc/odoo/
#RUN chown odoo /etc/odoo/openerp-server.conf
COPY ./entrypoint.sh $BASE_HOME$ODOO_HOME


RUN chown $ODOO_USER:$ODOO_USER -R $BASE_HOME/* \
        && chown $ODOO_USER:$ODOO_USER -R /var/*
USER $ODOO_USER

# Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
#RUN mkdir -p /mnt/extra-addons \
#        && chown -R odoo /mnt/extra-addons
#VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071

## Set default user when running the container
#USER odoo

#ENTRYPOINT ["/opt/odoo/server/entrypoint.sh"]
#ENTRYPOINT ["python","odoo.py","-c","/opt/odoo/server/openerp-server.conf"]
CMD ["python","odoo.py","-c","/opt/odoo/server/openerp-server.conf"]
