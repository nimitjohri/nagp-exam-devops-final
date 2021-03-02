def scmVars
pipeline {
    agent any
    tools {
        maven 'M3'
    }
    environment {
        GIT_BRANCH='${params.Environment}'
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
                    echo "${env.GIT_BRANCH}"
                    echo scmVars.GIT_BRANCH
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
                    bat 'mvn test'
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


        stage('Docker Build') {
            steps {
                script {
                    if (scmVars.GIT_BRANCH == 'origin/develop') {
                        bat 'docker build -t nimit07/nagp-devops-exam-final-develop:%BUILD_NUMBER% --no-cache -f Dockerfile .'
                    } else if (scmVars.GIT_BRANCH == 'origin/feature') {
                        bat 'docker build -t nimit07/nagp-devops-exam-final-feature:%BUILD_NUMBER% --no-cache -f Dockerfile .'
                    }
                }
            }
        }

        stage('Docker Push') {
            steps {
                bat 'docker login -u nimit07 -p Human@123'
                script {
                    if (scmVars.GIT_BRANCH == 'origin/develop') {
                        bat 'docker push nimit07/nagp-devops-exam-final-develop:%BUILD_NUMBER%'
                    } else if (scmVars.GIT_BRANCH == 'origin/feature') {
                        bat 'docker push -t nimit07/nagp-devops-exam-final-feature:%BUILD_NUMBER%'
                    }
                }
            }
        }

        stage('Stop Running Containers') {
            steps {
                script {
                    if (scmVars.GIT_BRANCH == 'origin/develop') {
                        bat'''
                        for /f %%i in ('docker ps -aqf "name=^nagp-devops-exam-final-develop"') do set containerId=%%i
                        echo %containerId%
                        if "%containerId%" == "" (
                            echo 'No Container Running'
                        ) else (
                            docker stop %containerId%
                            docker rm -f %containerId%
                        )
                        '''
                    } else if (scmVars.GIT_BRANCH == 'origin/feature') {
                        bat'''
                        for %f %%i in ('docker ps -aqf "name=^nagp-devops-exam-final-feature"') do set containerId=%%i
                        echo %containerId%
                        if "%containerId%" == "" (
                            echo 'No Container Running'
                        ) else (
                            docker stop %containerId%
                            docker rm -f %containerId%
                        )
                        '''
                    }
                }
            }
        }

        stage ('Docker Deployment') {
            steps {
                script {
                    if (scmVars.GIT_BRANCH == 'origin/develop') {
                        bat 'docker run --name nagp-devops-exam-final-develop -d -p 6500:8080 nimit07/nagp-devops-exam-final-develop:%BUILD_NUMBER%'
                    } else if (scmVars.GIT_BRANCH == 'origin/feature') {
                        bat 'docker run --name nagp-devops-exam-final-feature -d -p 6600:8080 nimit07/nagp-devops-exam-final-feature:%BUILD_NUMBER%'
                    }

                }
            }
        }
    }
}