def scmVars
pipeline {
    agent any
    tools {
        maven 'M3'
    }
    environment {
        GIT_BRAMCH: ${params.Environment}
    }
    options {
        timestamps()
        timeout(time: 1, unit: 'HOURS')
        skipDefaultCheckout()
        buildDiscarder(logRotator(daysToKeepStr: '10', numToKeepStr: '10'))
    }

    stages {
        stage ('Checkout') {
            steps {
                script {
                    scmVars = checkout scm
                    echo ${env.GIT_BRAMCH}
                }
            }
        }

        stage ('Build') {
            steps {
                script {
                    bat 'mvn clean install'
                }
            }
        }

        stage ('Unit Testing') {
            steps {
                script {
                    bat 'mvn Test'
                }
            }
        }

        stage ('Sonar Analysis') {
            steps {
                withSonarQubeEnv('SonarQube 8.4') {
                    bat 'mvn sonar:sonar'
                }
            }
        }

        stage ('Upload to Artifactory') {
            steps {
                script {
                    rtMavenDeployer(
                        id: 'deployer',
                        serverId: 'artifactory 6.20',
                        snapshotRepo: 'nagp-devops-exam-final',
                        releaseRepo: 'nagp-devops-exam-final'
                    )

                    rtMavenRun(
                        pom: 'pom.xml',
                        goals: 'clean install',
                        deployerId: 'deployer'
                    )

                    rtPublishBuildInfo(
                        serverId: 'artifactory 6.20'
                    )
                }
            }
        }


        // stage('Docker Build') {

        // }

    }
}