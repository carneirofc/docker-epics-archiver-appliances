# Docker images for the EPICS Archiver Appliances

Docker containers holding the EPICS archiver appliances. This repository defines three images: a base image and two others that extend it. Folders `images-single` and `images` provide images in which all servlets are deployed in either a single or 4 different containers, respectively.

## Environment variables

This image requires the following parameters when it is executed:

| VARIABLE                | DESC                                                                                                     | DEFAULT |
| ----------------------- | -------------------------------------------------------------------------------------------------------- | ------- |
| USE_AUTHENTICATION      | (`true`or`false`): variable that determines if a LDAP server should be used.                             | false   |
| CERTIFICATE_PASSWORD    | self-signed certificate's password.                                                                      |         |
| CONNECTION_URL          | LDAP server addresses. Used when`USE_AUTHENTICATION=true` only.                                          |         |
| ALTERNATIVE_URL         | LDAP server addresses. Used when`USE_AUTHENTICATION=true` only.                                          |         |
| CONNECTION_USER_FILTER  | is the user filter. Used when`USE_AUTHENTICATION=true` only.                                             |         |
| CONNECTION_USER_BASE    | is the LDAP user base distinguished name. Used when`USE_AUTHENTICATION=true` only.                       |         |
| CONNECTION_NAME         | is the binding distinguished name used for LDAP authentication. Used when`USE_AUTHENTICATION=true` only. |         |
| CONNECTION_PASSWORD     | is the binding password. Used when`USE_AUTHENTICATION=true` only.                                        |         |
| MYSQL_USER              |                                                                                                          |         |
| MYSQL_PASSWORD          |                                                                                                          |         |
| MYSQL_DATABASE          |                                                                                                          |         |
| MYSQL_PORT              |                                                                                                          |         |
| APPLIANCE_BASE_JMX_PORT | base JMX port used when launching each appliance. For each appliance the port will increase by one.      | 9050    |
| JAVA_OPTS               | JVM parameters need to be used                                                                           |         |
| JAVA_OPTS_ENGINE        | JVM parameters to be included on the specific tomcat container                                           |         |
| JAVA_OPTS_RETRIEVAL     | JVM parameters to be included on the specific tomcat container                                           |         |
| JAVA_OPTS_ETL           | JVM parameters to be included on the specific tomcat container                                           |         |
| JAVA_OPTS_MGMT          | JVM parameters to be included on the specific tomcat container                                           |         |
| BASE_TOMCAT_SRV_PORT    | Base Tomcat server port                                                                                  | 16000   |

## Building

1. Execute `build-docker-generic-appliance.sh` to build the base image for all the containers which will hold the appliances.
2. Change the working directory to `images` (or `images-single`) and execute `build-images.sh` (or `build-images-single.sh`). It will build 4 different images, one for each appliance (or a single one containing all appliances). Before doing that, you may change `setup-appliance.sh` up with your LDAP connection settings. The following command changes the servlet authentication preferences and should be modified with your server settings in case you use it.

```
# Appends new realm
xmlstarlet ed -L -s '/Server/Service/Engine/Host' -t elem -n "Realm" \
                 -i '/Server/Service/Engine/Host/Realm' -t attr -n "connectionURL" -v "ldap://ad1.abtlus.org.br:389" \
                 -i '/Server/Service/Engine/Host/Realm' -t attr -n "alternativeURL" -v "ldap://ad2.abtlus.org.br:389" \
                 -i '/Server/Service/Engine/Host/Realm' -t attr -n "userSearch" -v "(sAMAccountName={0})" \
                 -i '/Server/Service/Engine/Host/Realm' -t attr -n "userSubtree" -v "true" \
                 -i '/Server/Service/Engine/Host/Realm' -t attr -n "userBase" -v "OU=LNLS,DC=abtlus,DC=org,DC=br" \
                 -i '/Server/Service/Engine/Host/Realm' -t attr -n "connectionName" -v "${CONNECTION_NAME}" \
                 -i '/Server/Service/Engine/Host/Realm' -t attr -n "connectionPassword" -v "${CONNECTION_PASSWORD}" \
                 -i '/Server/Service/Engine/Host/Realm' -t attr -n "className" -v "org.apache.catalina.realm.JNDIRealm" \
                 ${CATALINA_HOME}/conf/server.xml

```

Besides the LDAP settings, you may edit the following command with your certificate's right password (`PASSWORD`).

```
# Imports certificate into trusted keystore
keytool -import -alias tomcat -trustcacerts -storepass ${CERTIFICATE_PASSWORD} -noprompt -keystore $JAVA_HOME/lib/security/cacerts -file ${APPLIANCE_FOLDER}/build/cert/archiver-mgmt.crt
```

However, the suggested approach is to pass those parameters as environment variables when the containers are deployed. For further details, refer to this [project](https://github.com/lnls-sirius/docker-epics-archiver-composed).

3. Another image containing all 4 appliances is available in `images-single`. To build it, execute `build-images-single.sh`. The same considerations about the variables are kept for this case.

## Running

Use these images with Docker Compose, Swarm or Kubernetes, according to this [project](https://github.com/lnls-sirius/docker-epics-archiver-composed). For development, we suggest to use the [docker-compose](https://docs.docker.com/compose/) tool, since no swarm is required. Enjoy!

## Dockerhub

All images described by this project were pushed into [this Dockerhub repo](https://hub.docker.com/u/lnlscon/).
