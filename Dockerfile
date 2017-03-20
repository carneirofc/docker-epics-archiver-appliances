
FROM tomcat:9

MAINTAINER Gustavo Ciotto

# user root is required to install all needed packages
USER root

ENV APPLIANCE_NAME epics-archiver-appliances

ENV APPLIANCE_FOLDER /opt/${APPLIANCE_NAME}

RUN mkdir -p ${APPLIANCE_FOLDER}/build/scripts

COPY docker-update.sh \
     ${APPLIANCE_FOLDER}/build/scripts/

WORKDIR ${APPLIANCE_FOLDER}/build/scripts/

RUN ./docker-update.sh

ENV ARCHAPPL_SITEID lnls-control-archiver

ENV EPICS_BASE_VERSION 3.14.12.6
ENV EPICS_BASE_TAR_NAME baseR${EPICS_BASE_VERSION}
ENV EPICS_BASE_NAME base-${EPICS_BASE_VERSION}
ENV EPICS_BASE_URL https://www.aps.anl.gov/epics/download/base/${EPICS_BASE_TAR_NAME}.tar.gz
ENV EPICS_INSTALL_DIR /opt

ENV EPICS_HOST_ARCH linux-x86_64
ENV EPICS_INSTALL_DIR /opt/base-3.14.12.6/bin/${EPICS_HOST_ARCH}
ENV EPICS_CA_ADDR_LIST 10.0.4.69
ENV EPICS_BASE ${EPICS_INSTALL_DIR}/${EPICS_BASE_NAME}
ENV PATH ${EPICS_INSTALL_DIR}/${EPICS_BASE_NAME}/bin/${EPICS_HOST_ARCH}:$PATH

COPY env-vars.sh \
     docker-setup-epics.sh \
     ${APPLIANCE_FOLDER}/build/scripts/

RUN ./docker-setup-epics.sh

COPY docker-setup-appliances.sh \
	 ${APPLIANCE_FOLDER}/build/scripts/

RUN ./docker-setup-appliances.sh

RUN mkdir -p ${APPLIANCE_FOLDER}/build/bin

RUN wget -P ${APPLIANCE_FOLDER}/build/bin https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.41.tar.gz

ENV MYSQL_CONNECTOR mysql-connector-java-5.1.41

RUN tar -C ${APPLIANCE_FOLDER}/build/bin -xvf ${APPLIANCE_FOLDER}/build/bin/${MYSQL_CONNECTOR}.tar.gz

RUN cp ${APPLIANCE_FOLDER}/build/bin/${MYSQL_CONNECTOR}/${MYSQL_CONNECTOR}-bin.jar ${CATALINA_HOME}/lib

RUN rm -R ${APPLIANCE_FOLDER}/build/bin/${MYSQL_CONNECTOR}/

RUN mkdir -p ${APPLIANCE_FOLDER}/build/configuration

COPY lnls_appliances.xml \
     lnls_policies.py \
     ${APPLIANCE_FOLDER}/build/configuration/

RUN mkdir -p ${APPLIANCE_FOLDER}/storage

# ARCHAPPL_APPLIANCES is always the same for every image, but ARCHAPPL_MYIDENTITY is not. So it needs to be 
# defined when the container is started
ENV ARCHAPPL_APPLIANCES ${APPLIANCE_FOLDER}/build/configuration/lnls_appliances.xml
ENV ARCHAPPL_POLICIES ${APPLIANCE_FOLDER}/build/configuration/lnls_policies.py
ENV ARCHAPPL_SHORT_TERM_FOLDER ${APPLIANCE_FOLDER}/storage/sts
ENV ARCHAPPL_MEDIUM_TERM_FOLDER ${APPLIANCE_FOLDER}/storage/mts
ENV ARCHAPPL_LONG_TERM_FOLDER ${APPLIANCE_FOLDER}/storage/lts

RUN mkdir -p ${ARCHAPPL_SHORT_TERM_FOLDER}
RUN mkdir -p ${ARCHAPPL_MEDIUM_TERM_FOLDER}
RUN mkdir -p ${ARCHAPPL_LONG_TERM_FOLDER}


