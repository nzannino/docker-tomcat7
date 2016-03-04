#!/bin/sh

if [ ! -f ${CATALINA_HOME}/bin/.tomcat_admin_created ]; then
    ${CATALINA_HOME}/bin/create_tomcat_admin_user.sh
fi

echo "Calling the tomcat startup script..."
exec /bin/su tomcat ${CATALINA_HOME}/bin/catalina.sh run 2>&1