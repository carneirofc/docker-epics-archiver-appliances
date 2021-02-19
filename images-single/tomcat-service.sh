#!/bin/sh
# A simple script to start tomcat service. This script blocks and does not
# allow the container to finish and end.
set -a
set -e
set -u

# Waits for MySQL database to start
chmod +x ${APPLIANCE_FOLDER}/build/configuration/wait-for-it/wait-for-it.sh
${APPLIANCE_FOLDER}/build/configuration/wait-for-it/wait-for-it.sh epics-archiver-mysql-db:3306

# Setup all appliances
${APPLIANCE_FOLDER}/build/scripts/setup-appliance.sh

export JMX_PORT=${APPLIANCE_BASE_JMX_PORT}
for APPLIANCE_UNIT in "engine" "retrieval" "etl" "mgmt"; do

    JAVA_OPTS_APPLIANCE=""
    set +u
    if [ "${APPLIANCE_UNIT}" = "engine" ]; then
        JAVA_OPTS_APPLIANCE=${JAVA_OPTS_ENGINE}
    fi

    if [ "${APPLIANCE_UNIT}" = "retrieval" ]; then
        JAVA_OPTS_APPLIANCE=${JAVA_OPTS_RETRIEVAL}
    fi

    if [ "${APPLIANCE_UNIT}" = "etl" ]; then
        JAVA_OPTS_APPLIANCE=${JAVA_OPTS_ETL}
    fi

    if [ "${APPLIANCE_UNIT}" = "mgmt" ]; then
        JAVA_OPTS_APPLIANCE=${JAVA_OPTS_MGMT}
    fi
    set -u

    JMX_OPTS=""
    JMX_OPTS="${JMX_OPTS} -Dcom.sun.management.jmxremote"
    JMX_OPTS="${JMX_OPTS} -Dcom.sun.management.jmxremote.port=${JMX_PORT}"
    JMX_OPTS="${JMX_OPTS} -Dcom.sun.management.jmxremote.ssl=false"
    JMX_OPTS="${JMX_OPTS} -Dcom.sun.management.jmxremote.authenticate=false"

    set -x
    echo "---- Appliance ${APPLIANCE_UNIT} ---- JMX_PORT=${JMX_PORT}"
    export CATALINA_BASE=${CATALINA_HOME}/${APPLIANCE_UNIT}
    export CATALINA_OPTS="${JAVA_OPTS_APPLIANCE} ${JAVA_OPTS} ${JMX_OPTS} -Dlog4j.debug"
    ${CATALINA_HOME}/bin/catalina.sh start
    set +x
    JMX_PORT=$((JMX_PORT + 1))
done

tail -f /dev/null
