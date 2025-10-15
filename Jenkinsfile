#!/usr/bin/env groovy

pipeline {
    agent any
    
    parameters {
        string(
            name: 'DOCKERFILE',
            defaultValue: 'Dockerfile.al2023',
            description: 'Which Dockerfile to build (e.g., Dockerfile.al2023)'
        )
    }
    
    environment {
        ECR_REGISTRY = '078742956215.dkr.ecr.us-east-1.amazonaws.com'
        IMAGE_NAME = 'kuali/kfs-apache-base'
        ECR_REPO = "${ECR_REGISTRY}/${IMAGE_NAME}"
        BUILD_DATE = sh(
            script: 'TZ="America/New_York" date +"%Y%m%d-%H%M%S%Z"',
            returnStdout: true
        ).trim()
        BRANCH_NAME_CLEAN = sh(
            script: 'echo ${BRANCH_NAME} | sed "s|/|_|g"',
            returnStdout: true
        ).trim()
    }
    
    stages {
        stage('ECR Login') {
            steps {
                sh '''
                    aws ecr get-login-password --region us-east-1 | \
                    docker login --username AWS --password-stdin ${ECR_REGISTRY}
                '''
            }
        }
        
        stage('Build Base Image') {
            steps {
                script {
                    echo "Building ${IMAGE_NAME} from ${params.DOCKERFILE}"
                    echo "Branch: ${BRANCH_NAME_CLEAN}"
                    echo "Build Date: ${BUILD_DATE}"
                    
                    sh """
                        docker build --no-cache --progress=plain \
                            -f ${params.DOCKERFILE} \
                            -t ${ECR_REPO}:latest \
                            -t ${ECR_REPO}:web_${BRANCH_NAME_CLEAN} \
                            -t ${ECR_REPO}:web_${BRANCH_NAME_CLEAN}_${BUILD_DATE} \
                            .
                    """
                }
            }
        }
        
        stage('Push Tags') {
            steps {
                script {
                    echo "Pushing tags: latest, web_${BRANCH_NAME_CLEAN}, web_${BRANCH_NAME_CLEAN}_${BUILD_DATE}"
                    
                    sh """
                        docker push ${ECR_REPO}:latest
                        docker push ${ECR_REPO}:web_${BRANCH_NAME_CLEAN}
                        docker push ${ECR_REPO}:web_${BRANCH_NAME_CLEAN}_${BUILD_DATE}
                    """
                }
            }
        }
        
        stage('Summary') {
            steps {
                script {
                    echo """
                    =====================================================
                    Base Image Build Complete
                    =====================================================
                    Image: ${ECR_REPO}
                    Tags created:
                      - latest
                      - web_${BRANCH_NAME_CLEAN}
                      - web_${BRANCH_NAME_CLEAN}_${BUILD_DATE}
                    
                    To use this base for an environment build:
                    1. Use retag-docker-image job to create env-specific tags
                       Example: Tag 'latest' as 'dfa-test' for dfa-test env
                    2. Run build-docker-kuali-apache-al2023 with env=dfa-test
                       It will use BASE_TAG=dfa-test (the tag you created)
                    =====================================================
                    """
                }
            }
        }
    }
    
    post {
        always {
            cleanWs()
        }
    }
}
