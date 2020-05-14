// global variables

// GIT REPO
git_bussiness_app_project_repo="https://github.com/skoussou/springboot-business-app.git"
git_bussiness_app_project_branch = "master"
// Service Name
svc_name="business-application-service"

// namespaces
namespace_dev = "dev-pam-pipeline"
def namespace_acp = "stage-pam-pipeline"
def namespace_prd = "prod-pam-pipeline"	
// MAVEN Artifact Server
nexus_url="http://nexus-cicd-demo.apps.cluster-rhpam-109e.rhpam-109e.example.opentlc.com/repository/"
nexus_repository="maven-releases"


pipeline {
    
    //agent none
    agent {
        label 'maven'
    }
    
    stages {
        stage('Checkout Business App') {
          //agent {
          //  label 'maven'
          //}
          steps {
               //step([$class: 'WsCleanup'])
  			 git(
  			   url: "${git_bussiness_app_project_repo}",
  			   //credentialsId: 'bitbucket', // from credentials.xml in Jenkins
  			   branch: "${git_bussiness_app_project_branch}"
  			 )
             script {
             echo "#############################################################################################"     
             echo "#                                                                                           #"
             echo "#           Checking versions of tooling used for Java/Maven                                #"
             echo "#                                                                                           #"                   
             echo "#############################################################################################"                        
             //withMaven(
             //  maven: 'maven-3'
             //mavenSettingsConfig: 'poc-maven-settings'	// Maven settings.xml file defined with the Jenkins Config File Provider Plugin
             //) 
             sh "pwd"
             sh "mvn --version"
             sh "apache-maven-3.6.2/bin/mvn --version"

             // Extract version and other properties from the pom.xml     
             //def pom = readMavenPom file: "pom.xml"
             //APP_VERSION = pom.version
             //ARTIFACT_ID = pom.artifactId
             //GROUP_ID = pom.groupId

             //echo "APP_VERSION = ${APP_VERSION}"
             //echo "ARTIFACT_ID = ${ARTIFACT_ID}"
             //echo "GROUP_ID = ${GROUP_ID}"   

             // Extract version and other properties from the pom.xml
             //def groupId    = getGroupIdFromPom("pom.xml")
             //def artifactId = getArtifactIdFromPom("pom.xml")
             //def version    = getVersionFromPom("pom.xml")              
             
             //echo "groupId: ${groupId}"
             //echo "artifactId: ${artifactId}"
             //echo "version: ${version}" 

             }
          }
        }
        
       
                
        stage('Build/Test App & Create Offliner KJAR Dependencies Repo') {
          //agent {
          //  label 'maven'
          //}
          steps {
             script {
             echo "#############################################################################################"     
             echo "#                                                                                           #"
             echo "#           Build KJARs Maven Dependencies local Repository                                 #"
             echo "#                                                                                           #"                   
             echo "#############################################################################################"       			   
    			   
             sh "apache-maven-3.6.2/bin/mvn clean package -P openshift-docker -Dmaven.artifact.threads=50 -s settings-nexus.xml"
             sh "ls -la local-m2-repository-offliner/com/redhat"
             sh "tree local-m2-repository-offliner/com/redhat"  
             }
          }
        }

        stage('Deploy to Nexus') {
          //agent {
          //  label 'maven'
          //}
          steps {
             script {
                 
              sh "apache-maven-3.6.2/bin/mvn deploy -DaltReleaseDeploymentRepository=$nexus_repository::default::$nexus_url$nexus_repository -s settings-nexus.xml"            
             }
          }
        }


        stage("Build/Deploy into Dev Namespace") {
           // agent any
            steps {
                script {
                    //openshift.withCluster( 'mytempcloudcluster', 'rhn-gps-stkousso' ) {
                        echo "Hello from ${openshift.cluster()}'s default project: ${openshift.project()}"
        
                        // But we can easily change project contexts
                        //openshift.withProject( "$namespace_dev" ) {
                            echo "Creating and Running build in project: ${openshift.project()}"
                            script {                        
                                

                                //sh "apache-maven-3.6.2/bin/mvn fabric8:build -Dfabric8.namespace=$namespace_dev -DskipTests=true -P openshift -Dmaven.artifact.threads=50 -s settings-nexus.xml  -X"
                                //sh "oc start-build business-application-service --from-dir=. -n $namespace_dev"
                                
                                // works but no Service and no route
                                //sh "apache-maven-3.6.2/bin/mvn install -Dfabric8.namespace=$namespace_dev -DskipTests=true -P openshift-docker -Dmaven.artifact.threads=50 -s settings-nexus.xml  -X"
                                
                                sh "apache-maven-3.6.2/bin/mvn fabric8:deploy -Dfabric8.namespace=$namespace_dev -DskipTests=true -P openshift-docker -Dmaven.artifact.threads=50 -s settings-nexus.xml"
                                
                            }
                            
                        //}
                    //}
                }
            }
        }

        stage("Deploy in Stage Namespace") {
            steps {
                script {
                   def pom = readMavenPom file: "pom.xml"
                   APP_VERSION = pom.version

		           echo "APP_VERSION: ${APP_VERSION}"

                   //sh "ocp-resources/oc rollout latest dc ${svc_name} -n ${namespace_acp}"
                   echo "ocp-resources/oc set triggers dc/${svc_name} --from-image ${namespace_dev}/${svc_name}:${APP_VERSION} --containers=${namespace_acp}-${svc_name} -n ${namespace_acp}"
		           sh "oc set triggers dc/${svc_name} --from-image ${namespace_dev}/${svc_name}:${APP_VERSION} --containers=${namespace_acp}-${svc_name} -n ${namespace_acp}"
		  // Consider Tekton and Argo https://argoproj.github.io/argo-cd/


                }
            }
        }

        stage("Deploy in Prod Namespace") {
            steps {
                script {
                   version = getVersionFromPom("pom.xml") 
                   
                   echo "version: ${version}"

                   //sh "ocp-resources/oc rollout latest dc ${svc_name} -n ${namespace_prd}"   
                   echo "ocp-resources/oc set triggers dc/${svc_name} --from-image ${namespace_dev}/${svc_name}:${version} --containers=${namespace_prd}-${svc_name} -n ${namespace_prd}"
		           sh "oc set triggers dc/${svc_name} --from-image ${namespace_dev}/${svc_name}:${version} --containers=${namespace_prd}-${svc_name} -n ${namespace_prd} -n ${namespace_prd}"
		  // Consider Tekton and Argo https://argoproj.github.io/argo-cd/
 
                }
            }
        }


    }

}

// Convenience Functions to read variables from the pom.xml
// Do not change anything below this line.
// --------------------------------------------------------
def getVersionFromPom(pom) {
  def matcher = readFile(pom) =~ '<version>(.+)</version>'
  matcher ? matcher[0][1] : null
}
def getGroupIdFromPom(pom) {
  def matcher = readFile(pom) =~ '<groupId>(.+)</groupId>'
  matcher ? matcher[0][1] : null
}
def getArtifactIdFromPom(pom) {
  def matcher = readFile(pom) =~ '<artifactId>(.+)</artifactId>'
  matcher ? matcher[0][1] : null
}

