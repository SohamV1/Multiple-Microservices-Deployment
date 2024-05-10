pipeline {
    agent any
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        AWS_ACCOUNT_ID = credentials('ACCOUNT_ID')
        AWS_DEFAULT_REGION = 'us-east-1'
        REPO_PREFIX = "407622020962.dkr.ecr.us-east-1.amazonaws.com/multiple-microservices-kubernetes-deployment"
    }
    stages {
        stage("Cleaning Workspace") {
            steps {
                cleanWs()
            }
        }
        stage("Checkout from git") {
            steps {
                git credentialsId: 'github', url: 'https://github.com/SohamV1/Multiple-Microservices-Deployment.git'
            }
        }
        stage("Sonarqube Analysis") {
            steps {
                dir('src'){
                    withSonarQubeEnv('sonar-server') {
                        sh ''' 
                            ${SCANNER_HOME}/bin/sonar-scanner \
                            -Dsonar.projectKey=Multiple-Microservices-Deployment  \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=http://localhost:9000 \
                            -Dsonar.exclusions=**/*.java 
                        '''
                    }
                }
            }
        }
        stage('Quality Check') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-token' 
                }
            }
        }
        stage('OWASP Dependency-Check Scan') {
            steps {
                dir('src') {
                    dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                    dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
                }
            }
        }
        stage('Trivy File Scan') {
            steps {
                dir('src') {
                    sh 'trivy fs . > trivyfs.txt'
                }
            }
        }
        stage("Docker image build and ECR push"){
            steps{
                script{
                   dir('Scripts'){    
                        sh 'sudo chmod +755 make-docker.sh && bash make-docker.sh'                        
                   }
                }
            }
        }
    }
}
