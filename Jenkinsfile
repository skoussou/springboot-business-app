// global variables
git_bussiness_app_project_repo="https://github.com/skoussou/springboot-business-app.git"
git_bussiness_app_project_branch = "master"




// namespaces
// WORKS HERE after SA / SECRET changes to default SA and Builder SA def namespace_dev = "dev-pam"
namespace_dev = "dev-pam"
def namespace_acp = "dev-stage"
//def namespace_prd = "dev-prod"	

nexus_url="http://nexus-cicd-demo.apps.cluster-workshop-07d8.workshop-07d8.example.opentlc.com/repository/"
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
           // agent any
            steps {
                script {

                            }
                            
                        //}
                    //}
                }
            }
        }

        stage("Deploy in Prod Namespace") {
           // agent any
            steps {
                script {

                            }
                            
                        //}
                    //}
                }
            }
        }


    }

}

