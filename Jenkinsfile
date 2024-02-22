pipeline {
    agent { dockerfile true }
    stages {
        stage('Test') {
            steps {
                sh 'grep -E "^(VERSION|NAME)=" /etc/os-release'
                sh 'apache2ctl -t'
            }
        }
    }
}
