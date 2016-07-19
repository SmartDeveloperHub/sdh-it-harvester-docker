FROM alejandrofcarrera/phusion.maven
MAINTAINER Miguel Esteban Gutierrez

# Exports
ENV HARVESTER_HOME="/opt/it-harvester-backend"

# Uncomment to include in the image a configuration file and related contributor 
# mail mappings (e.g., files/collector.cfg & files/contributor.mails)
 ENV CONFIG=$HARVESTER_HOME/collector.cfg
 COPY files/collector.cfg $HARVESTER_HOME/collector.cfg
 COPY files/contributor.mails $HARVESTER_HOME/contributor.mails

# Configure runit
ADD ./my_init.d/ /etc/my_init.d/
ONBUILD ADD ./my_init.d/ /etc/my_init.d/

CMD ["/sbin/my_init"]
