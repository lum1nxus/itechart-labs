pipeline {
    agent {label 'swarm'}

    stages {
        stage('Build') {
            steps {
                git credentialsId: 'github-ssh-key', url: 'git@github.com:cosmicjs/landing-page.git'
            }
            post {
                success{
                        sshPublisher(publishers: [sshPublisherDesc(configName: 'MyWebServer', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '''cd /home/landing-page
                        sudo npm install
                        sudo npm install express
                        sudo npm install hogan-express
                        sudo npm install http-errors
                        sudo npm install debug
                        sudo npm install morgan
                        sudo npm install jade
                        sudo npm install cookie-parser
                        sudo npm install cosmicjs
                        sudo yarn start''', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: '/home/landing-page', remoteDirectorySDF: false, removePrefix: '', sourceFiles: '**/*')], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                }
            }
            }
        }
    }