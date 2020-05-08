FROM registry.redhat.io/redhat-openjdk-18/openjdk18-openshift
ENV JAVA_OPTIONS="-Dorg.drools.server.filter.classes=true -Dspring.profiles.active=openshifth2 -Dorg.kie.server.startup.strategy=LocalContainersStartupStrategy -Dorg.kie.server.mode=PRODUCTION -Dkie.maven.settings.custom=/opt/jboss/.m2/settings.xml -Dorg.guvnor.m2repo.dir=/opt/jboss/.m2/repository -Dapplied=dockerfile"
EXPOSE 8090
#COPY maven /tmp/131cca24-11f4-4387-8ef3-0ef7bbb4a166/

COPY target/business-application-service-2.2.13.jar /deployments/
COPY business-application-service.xml /deployments/
COPY ./src/main/docker/settings.xml /opt/jboss/.m2/settings.xml
COPY local-m2-repository-offliner /opt/jboss/.m2/repository


USER root

RUN chgrp -Rf root /opt/jboss && chmod -Rf g+w /opt/jboss
RUN chgrp -Rf root /deployments && chmod -Rf g+w /deployments

USER jboss
