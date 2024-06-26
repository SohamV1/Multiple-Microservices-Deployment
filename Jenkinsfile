pipeline {
    agent any
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        AWS_ACCOUNT_ID = credentials('ACCOUNT_ID')
        AWS_DEFAULT_REGION = 'us-east-1'
        REPO_PREFIX = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com/"
        GIT_REPO="Multiple-Microservices-Deployment"
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
                        sh 'bash make-docker.sh'                        
                   }
                }
            }
        }
        stage("Update Deployment file"){
            steps{
                withCredentials([usernamePassword(credentialsId: 'github', usernameVariable: 'GIT_USER_NAME', passwordVariable: 'GITHUB_TOKEN')]) {
                    dir('Scripts'){
                        sh 'bash make-release.sh'
                    }
                }
            }
        }
    }
}
