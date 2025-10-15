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
    
    stages {
        stage('Checkout cloud-utils') {
            steps {
                dir('cloud-utils') {
                    git(
                        url: 'https://github.com/CU-CommunityApps/cloud-utils.git',
                        credentialsId: 'jenkins-cukfs',
                        branch: 'master'
                    )
                }
            }
        }
        
        stage('Build and Push Base Image') {
            steps {
                script {
                    // For multibranch pipeline, JOB_NAME includes branch like "job/branch"
                    // Extract just the base job name for pipe mechanism
                    def baseJobName = env.JOB_NAME.replaceAll('/.*', '')
                    def lockFile = "/jenkins_home/pipe/lock/${baseJobName}"
                    def pipe = "/var/jenkins_home/pipe/${baseJobName}"
                    def workspaceInContainer = env.WORKSPACE
                    // On host, workspace is mounted without /var prefix
                    def workspaceOnHost = workspaceInContainer.replaceAll('^/var', '')
                    def buildDate = sh(script: 'TZ="America/New_York" date +"%Y%m%d-%H%M%S%Z"', returnStdout: true).trim()
                    def branchClean = env.BRANCH_NAME.replaceAll('/', '_')
                    
                    def imageName = "kfs-apache-base"
                    def ecrRepo = "078742956215.dkr.ecr.us-east-1.amazonaws.com/kuali/${imageName}"
                    
                    echo "Building ${imageName} from ${params.DOCKERFILE}"
                    echo "Branch: ${branchClean}"
                    echo "Build Date: ${buildDate}"
                    echo "Workspace in container: ${workspaceInContainer}"
                    echo "Workspace on host: ${workspaceOnHost}"
                    
                    // Use pipe mechanism like other jobs
                    // Paths in pipeCommand run on HOST, so use workspaceOnHost
                    def pipeCommand = """touch ${lockFile} && \\
${workspaceOnHost}/cloud-utils/bin/ecr-login.sh && \\
echo "Building base image ${imageName}" && \\
docker build --no-cache --progress=plain \\
    -f ${workspaceOnHost}/${params.DOCKERFILE} \\
    -t ${ecrRepo}:latest \\
    -t ${ecrRepo}:apache-base_${branchClean} \\
    -t ${ecrRepo}:apache-base_${branchClean}_${buildDate} \\
    ${workspaceOnHost} && \\
echo "Pushing tags: latest, apache-base_${branchClean}, apache-base_${branchClean}_${buildDate}" && \\
docker push ${ecrRepo}:latest && \\
docker push ${ecrRepo}:apache-base_${branchClean} && \\
docker push ${ecrRepo}:apache-base_${branchClean}_${buildDate} && \\
rm -f ${lockFile} || \\
( rm -f ${lockFile} && touch ${workspaceOnHost}/failed.txt )"""
                    
                    echo pipeCommand
                    
                    // Write command to pipe
                    sh "echo '${pipeCommand}' > ${pipe}"
                    
                    // Wait for execution
                    sh "sleep 2"
                    sh """
                        while [ -e /var${lockFile} ]; do
                            sleep 30
                        done
                    """
                    sh "sleep 2"
                    
                    // Show output
                    sh "cat ${pipe}-output.txt"
                    
                    // Check for failure
                    sh """
                        if [ -f ${workspaceInContainer}/failed.txt ]; then
                            exit 1
                        fi
                    """
                    
                    echo """
                    =====================================================
                    Base Image Build Complete
                    =====================================================
                    Image: ${ecrRepo}
                    Tags created:
                      - latest
                      - apache-base_${branchClean}
                      - apache-base_${branchClean}_${buildDate}
                    
                    To use this base for an environment build:
                    1. Use retag-docker-image job to create env-specific tags
                       Example: destination_tag=latest, tag_to_be_moved=dfa-test
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
