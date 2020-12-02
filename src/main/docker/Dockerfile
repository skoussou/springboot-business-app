FROM registry.redhat.io/redhat-openjdk-18/openjdk18-openshift

ENV JAVA_OPTIONS="-Dorg.drools.server.filter.classes=true -Dspring.profiles.active=openshift -Dorg.kie.server.startup.strategy=LocalContainersStartupStrategy -Dorg.kie.server.mode=PRODUCTION -Dkie.maven.settings.custom=/opt/jboss/.m2/settings.xml -Dorg.guvnor.m2repo.dir=/opt/jboss/.m2/repository -Dapplied=dockerfile"
EXPOSE 8090

#COPY target/business-application-service-2.2.20.jar /deployments/
#COPY business-application-service.xml /deployments/
#COPY ./src/main/docker/settings.xml /opt/jboss/.m2/settings.xml
#COPY local-m2-repository-offliner /opt/jboss/.m2/repository

COPY maven/business-application-service-3.0.0.jar/deployments/
COPY maven/business-application-service.xml /deployments/
COPY maven/settings.xml /opt/jboss/.m2/settings.xml



USER root

RUN chgrp -Rf root /opt/jboss/.m2 && chmod -Rf g+w /opt/jboss/.m2
RUN chgrp -Rf root /deployments && chmod -Rf g+w /deployments

USER jboss
