FROM nzannino/docker-java7
MAINTAINER Nicola Zannino <n.zannino@gmail.com>

RUN apt-get update && \
    apt-get install -yq --no-install-recommends wget pwgen ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos '' tomcat

ENV CATALINA_HOME /usr/share/tomcat
ENV PATH $CATALINA_HOME/bin:$PATH
RUN mkdir -p "$CATALINA_HOME"
WORKDIR $CATALINA_HOME

ENV TOMCAT_MAJOR 7
ENV TOMCAT_VERSION 7.0.68
ENV TOMCAT_TGZ_URL https://www.apache.org/dist/tomcat/tomcat-$TOMCAT_MAJOR/v$TOMCAT_VERSION/bin/apache-tomcat-$TOMCAT_VERSION.tar.gz

RUN set -x \
	&& curl -fSL "$TOMCAT_TGZ_URL" -o tomcat.tar.gz \
	&& curl -fSL "$TOMCAT_TGZ_URL.asc" -o tomcat.tar.gz.asc \
	&& gpg --batch --verify tomcat.tar.gz.asc tomcat.tar.gz \
	&& tar -xvf tomcat.tar.gz --strip-components=1 \
	&& rm bin/*.bat \
	&& rm tomcat.tar.gz*

# Run Tomcat as a service with runit
RUN mkdir /etc/service/tomcat
COPY tomcat-run.sh /etc/service/tomcat/run
RUN chmod +x /etc/service/tomcat/run
RUN chown -R tomcat:tomcat /etc/service/tomcat

# Set Tomcat environment variables
COPY tomcat-setenv.sh ${CATALINA_HOME}/bin/setenv.sh
COPY create_tomcat_admin_user.sh ${CATALINA_HOME}/bin/create_tomcat_admin_user.sh
RUN chmod +x ${CATALINA_HOME}/bin/*.sh
RUN chown -R tomcat:tomcat ${CATALINA_HOME}

EXPOSE 8080 8009

# Clean up APT when done
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
CMD ["/sbin/my_init"]