FROM openjdk:8-alpine

RUN apk --no-cache add curl

# Set the WILDFLY_VERSION env variable
ENV WILDFLY_VERSION 17.0.1.Final
ENV WILDFLY_SHA1 eaef7a87062837c215e54511c4ada8951f0bd8d5
ENV JBOSS_HOME /opt/jboss/wildfly

USER root

# Add the WildFly distribution to /opt, and make wildfly the owner of the extracted tar content
# Make sure the distribution is available from a well-known place
RUN mkdir -p /opt/jboss
RUN adduser -D jboss
RUN cd $HOME \
    && curl -O https://download.jboss.org/wildfly/$WILDFLY_VERSION/wildfly-$WILDFLY_VERSION.tar.gz \
    && sha1sum wildfly-$WILDFLY_VERSION.tar.gz | grep $WILDFLY_SHA1 \
	&& tar xf wildfly-$WILDFLY_VERSION.tar.gz \
	&& mv $HOME/wildfly-$WILDFLY_VERSION $JBOSS_HOME \
    && rm wildfly-$WILDFLY_VERSION.tar.gz \
    && chown -R jboss:0 ${JBOSS_HOME} \
    && chmod -R g+rw ${JBOSS_HOME}

# Ensure signals are forwarded to the JVM process correctly for graceful shutdown
ENV LAUNCH_JBOSS_IN_BACKGROUND true

USER jboss

# Expose the ports we're interested in
EXPOSE 8080

# Set the default command to run on boot
# This will boot WildFly in the domain mode and bind to all interface
CMD ["/opt/jboss/wildfly/bin/domain.sh", "-b", "0.0.0.0"]
