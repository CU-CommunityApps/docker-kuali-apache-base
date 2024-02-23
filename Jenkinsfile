pipeline {
    agent { 
        dockerfile {
            registryUrl 'https://078742956215.dkr.ecr.us-east-1.amazonaws.com/kuali/kfs-apache-base'
            registryCredentialsId 'ecr:us-east-1:jenkins-aws'
        }
    }
    options {
        skipStagesAfterUnstable()
    }
    stages {
        stage('Test') {
            steps {
                sh 'grep -E "^(VERSION|NAME)=" /etc/os-release'
                sh 'apache2ctl -t'
            }
        }
    }
}
