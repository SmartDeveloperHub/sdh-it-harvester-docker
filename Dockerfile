FROM alejandrofcarrera/phusion.maven
MAINTAINER Miguel Esteban Gutierrez

# Exports
ENV HARVESTER_HOME="/opt/it-harvester"

COPY files/pom.xml $HARVESTER_HOME/pom.xml

# Uncomment to include in the image a local data file (i.e., files/local-data.json)
# ENV LOCAL_DATA=$HARVESTER_HOME/data/local-data.json
# COPY files/local-data.json $HARVESTER_HOME/data/local-data.json

# Configure runit
ADD ./my_init.d/ /etc/my_init.d/
ONBUILD ADD ./my_init.d/ /etc/my_init.d/

WORKDIR /opt/it-harvester
RUN mvn

CMD ["/sbin/my_init"]

EXPOSE 80
