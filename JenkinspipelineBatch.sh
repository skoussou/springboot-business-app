#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  $0 kjarlist[containerAlias-1#RuntimeStrategy#GIT_REPO-1,containerAlias-2#RuntimeStrategy#GIT_REPO-2,containerAlias-N#RuntimeStrategy#GIT_REPO-N] serviceName"
    exit 1
fi


KJAR_GAV_LIST=$1
SB_APP_SERVICE=$2
CONTAINERS_XML=""
KJAR_REPO=""

echo 
echo 
echo "Preparing KJARs   : $KJAR_GAV_LIST"
echo "Preparing Service : $SB_APP_SERVICE"
echo 
echo 

rm -rf ../kjar
mkdir ../kjar

#KJAR_GAV_LIST=(basic#PER_PROCESS_INSTANCE#https://github.com/skoussou/basic-kjar,retail#PER_CASE#https://github.com/skoussou/example-retail-credit-kjar)
#SB_APP_SERVICE=first-service

KJAR_GAV_LIST=($KJAR_GAV_LIST)

# The Springboot Business Service App Directory Name
APP_DIR=$(basename "$PWD")

# The path of the parent directory of the Springboot BUsiness Service App directory
PARENT_DIR_PATH=$(dirname "$PWD")



echo 
echo "Application Directory: $APP_DIR"
echo "Path                 : ${PARENT_DIR_PATH}/${APP_DIR}"
echo

array=(${KJAR_GAV_LIST//","/" "})

#array=(kjar1:http://github/kjar-1 kjar2:http://github/kjar-2 kjar3:http://github/kjar-3)

# ${#array[@]} is the number of elements in the array
for ((i = 0; i < ${#array[@]}; ++i)); do
    echo 
    # bash arrays are 0-indexed
    #position=$(( $i + 1 ))
    #echo "$position,${array[$i]}"
    echo '##################################################################################################################################'
    echo "#  PROCESS KJAR                                                                                           "
    echo "#  ${array[$i]}"
    tmp_array=${array[$i]}
    KJAR_DETAILS_ARRAY=(${tmp_array//"#"/" "})
    #for ((i = 0; i < ${#KJAR_DETAILS_ARRAY[@]}; ++i)); do
    KJAR_NAME=${KJAR_DETAILS_ARRAY[0]}
    echo "#  KJAR_NAME ==> $KJAR_NAME"
    KJAR_RUNTIME_STRATEGY=${KJAR_DETAILS_ARRAY[1]}
    echo "#  KJAR_RUNTIME_STRATEGY ==> $KJAR_RUNTIME_STRATEGY"
    KJAR_REPO=${KJAR_DETAILS_ARRAY[2]}
    echo "#  KJAR_REPO ==> $KJAR_REPO"
    echo '#---------------------------------------------------------------------------------------------------------------------------------'
    echo "  Clone the repo for [$KJAR_NAME] for which the Business Service will be created [$KJAR_REPO]"
    echo '#---------------------------------------------------------------------------------------------------------------------------------'
    echo "git -C ${PARENT_DIR_PATH}/kjar clone $KJAR_REPO"
    git -C ${PARENT_DIR_PATH}/kjar clone $KJAR_REPO
    echo 
    REPO_DIR="${KJAR_REPO##*/}"
    echo '#---------------------------------------------------------------------------------------------------------------------------------'
    echo "  Create local Repo dependencies for KJAR ["$KJAR_NAME"] repo [$KJAR_REPO]"
    echo '#---------------------------------------------------------------------------------------------------------------------------------'
    #echo "mvn -e -DskipTests dependency:go-offline -f ../kjar/$REPO_DIR/pom.xml --batch-mode -Djava.net.preferIPv4Stack=true -s ../springboot-business-app/settings.xml"
    #mvn -e -q -DskipTests dependency:go-offline -f ../kjar/$REPO_DIR/pom.xml --batch-mode -Djava.net.preferIPv4Stack=true -s ../springboot-business-app/settings.xml
    echo "mvn -e -DskipTests dependency:go-offline -f ../kjar/$REPO_DIR/pom.xml --batch-mode -Djava.net.preferIPv4Stack=true -s ../${APP_DIR}/settings.xml"
    mvn -e -q -DskipTests dependency:go-offline -f ../kjar/$REPO_DIR/pom.xml --batch-mode -Djava.net.preferIPv4Stack=true -s ../${APP_DIR}/settings.xml
    echo 
    echo '#---------------------------------------------------------------------------------------------------------------------------------'
    echo "  Build and Deploy to local repository the KJAR ["$KJAR_REPO"]"
    echo '#---------------------------------------------------------------------------------------------------------------------------------'
    #echo "mvn clean deploy -f ../kjar/$REPO_DIR/pom.xml -s ../springboot-business-app/settings.xml -DaltReleaseDeploymentRepository=local-nexus::default::file://.local-m2-repository"
    #mvn clean deploy -q -f ../kjar/$REPO_DIR/pom.xml -s ../springboot-business-app/settings.xml -DaltReleaseDeploymentRepository=local-nexus::default::file://.local-m2-repository
    echo "mvn clean install -q -f ../kjar/$REPO_DIR/pom.xml -s ../${APP_DIR}/settings.xml"
    mvn clean install -q -f ../kjar/$REPO_DIR/pom.xml -s ../${APP_DIR}/settings.xml
    echo
    xslt_cmd="xsltproc extract-gav.xsl ../kjar/$REPO_DIR/pom.xml"
#    RELEASE_ID=${xsltproc extract-gav.xsl ../kjar/$REPO_DIR/pom.xml}

    RELEASE_ID=$($xslt_cmd)
    #RELEASE_ID_TRIM=${RELEASE_ID//" "/""}
    #echo "RELEASE_ID_TRIM --> [$RELEASE_ID_TRIM]"

    echo $RELEASE_ID | grep -o -P '(?<=<groupId>).*(?=</groupId>)'
    echo $RELEASE_ID | grep -o -P '(?<=<artifactId>).*(?=</artifactId>)'
    echo $RELEASE_ID | grep -o -P '(?<=<version>).*(?=</version>)'

    KIE_ONTAINER_ARTIFACT=$(echo $RELEASE_ID | grep -o -P '(?<=<artifactId>).*(?=</artifactId>)')
    KIE_ONTAINER_VERSION=$(echo $RELEASE_ID | grep -o -P '(?<=<version>).*(?=</version>)')

    echo $RELEASE_ID
    CONTAINERS_XML="$CONTAINERS_XML<container>
      <containerId>$KIE_ONTAINER_ARTIFACT-$KIE_ONTAINER_VERSION</containerId>
      $RELEASE_ID
      <status>STARTED</status>
      <scanner>
        <status>STOPPED</status>
      </scanner>
      <configItems>
        <config-item>
          <name>KBase</name>
          <value></value>
          <type>BPM</type>
        </config-item>
        <config-item>
          <name>KSession</name>
          <value></value>
          <type>BPM</type>
        </config-item>
        <config-item>
          <name>MergeMode</name>
          <value>MERGE_COLLECTIONS</value>
          <type>BPM</type>
        </config-item>
        <config-item>
          <name>RuntimeStrategy</name>
          <value>$KJAR_RUNTIME_STRATEGY</value>
          <type>BPM</type>
        </config-item>
      </configItems>
      <messages/>
      <containerAlias>$KJAR_NAME</containerAlias>
    </container>"
    echo '##################################################################################################################################'


done

echo 
echo 
echo '##################################################################################################################################'
echo "  Create SB Business Configs ["$SB_APP_SERVICE"]"
echo '##################################################################################################################################'
#CONTAINERS_XML_TEMP=(${CONTAINERS_XML//" "/""})
CONTAINERS_XML="<containers>$CONTAINERS_XML</containers>"
##echo $CONTAINERS_XML | xmllint --format -
echo
echo "Update SB properties files with correct kieserver.serverId=$SB_APP_SERVICE and kieserver.serverName=$SB_APP_SERVICE"
echo 
KEYS=(kieserver.serverId kieserver.serverName)

properties_dir='./src/main/resources'
for ((i = 0; i < ${#KEYS[@]}; ++i)); do
    filename=""
    #properties_dir='./src/main/resources'


    #echo "ls $properties_dir |grep properties"
    #files_list=$("ls $properties_dir |grep properties")

    for entry in "$properties_dir"/*
      do
      if [[ $entry =~ \.properties$ ]]; then
        echo "Updating SB Props [$entry]"
        filename=$entry


        if ! grep -R "^[#]*\s*${KEYS[$i]}=.*" $filename > /dev/null; then
          echo "APPENDING because [${KEYS[$i]}] not found"
          echo "#kie server config"  >> $filename
          echo "=================="  >> $filename
          echo "${KEYS[$i]}=$SB_APP_SERVICE" >> $filename
        else
          echo "SETTING because [${KEYS[$i]}] found already"
          sed -ir "s/^[#]*\s*${KEYS[$i]}=.*/${KEYS[$i]}=$SB_APP_SERVICE/" $filename
        fi
        filename=""
      fi
    done    

done

#rm -r $properties_dir"/*.propertiesr"
rm -r ${PARENT_DIR_PATH}/${APP_DIR}"/src/main/resources/*.propertiesr"

echo
echo "Update/Create $SB_APP_SERVICE.xml with [$KJAR_GAV_LIST] to load the KJAR(s)"
XML_CONFIG="<kie-server-state>
  <controllers/>
  <configuration>
    <configItems>
      <!--config-item>
        <name>org.kie.server.controller</name>
        <value>ws://127.0.0.1:8080/business-central/websocket/controller</value>
        <type>java.lang.String</type>
      </config-item>
      <config-item>
        <name>org.kie.server.controller.user</name>
        <value>controllerUser</value>
        <type>java.lang.String</type>
      </config-item>
      <config-item>
        <name>org.kie.server.controller.pwd</name>
        <value>controllerUser1234;</value>
        <type>java.lang.String</type>
      </config-item-->
      <config-item>
        <name>org.kie.server.location</name>
        <value>http://localhost:8090/rest/server</value>
        <type>java.lang.String</type>
      </config-item>
      <config-item>
        <name>org.kie.server.user</name>
        <value>executionUser</value>
        <type>java.lang.String</type>
      </config-item>
      <config-item>
        <name>org.kie.server.pwd</name>
        <value>executionUser</value>
        <type>java.lang.String</type>
      </config-item>
      <config-item>
        <name>org.kie.server.id</name>
        <value>$SB_APP_SERVICE</value>
        <type>java.lang.String</type>
      </config-item>
      <config-item>
        <name>org.kie.server.startup.strategy</name>
        <value>LocalContainersStartupStrategy</value>
        <type>java.lang.String</type>
      </config-item>
      <config-item>
        <name>org.kie.server.mode</name>
        <value>DEVELOPMENT</value>
        <type>java.lang.String</type>
      </config-item>
    </configItems>
  </configuration>
  $CONTAINERS_XML
</kie-server-state>"
echo '#---------------------------------------------------------------------------------------------------------------------------------'
echo $XML_CONFIG | xmllint --format -
echo '#---------------------------------------------------------------------------------------------------------------------------------'
echo "$XML_CONFIG" > "$SB_APP_SERVICE.xml"
echo 
echo 


