def secret = 'jenkins-miralssh'
def buildServer = 'miral@34.101.172.163'
def frontendServer = 'miral@34.101.210.112'
def testLink = 'http://localhost:3000'
def directory = '~/project/wayshub-frontend'
def image = 'millinovz/wayshub-frontend:v1'
def branch = 'main'

pipeline{
    agent any
    
    environment {
        DISCORD_URL = credentials('DISCORD_WEBHOOK')
        WEB_STATUS = '';
    }

    stages{

        stage ('pulling new code'){
         steps{
             sshagent(credentials: [secret]) {
                    sh """ssh -o StrictHostKeyChecking=no ${buildServer} << EOF
                    cd ${directory}
		            git pull origin ${branch}
                    exit
                    EOF"""
                }
            }
        }

        stage ('build apps'){
            steps{
                sshagent(credentials: [secret]) {
                    sh """ssh -o StrictHostKeyChecking=no ${buildServer} << EOF
                    cd ${directory}
                    docker compose build
                    docker compose up -d
                    exit
                    EOF"""
                }
            }
        }
        
        stage ('test apps'){
            steps{
                // script {
                //     def command = 'curl -s -o /dev/null -w \"%{http_code} \\n\" ' + testLink 
    
                //     env.WEB_STATUS = sh(
                //         script: command, 
                //         returnStdout: true
                //     ).trim()

                //     echo "HTTP Status Code is ${env.WEB_STATUS}"
                // }
                
                sshagent(credentials: [secret]) {

                    sh """ssh -o StrictHostKeyChecking=no ${buildServer} << EOF """
                    script {
                        def command = 'curl -s -o /dev/null -w \"%{http_code} \\n\" ' + testLink 
        
                        env.WEB_STATUS = sh(
                            script: command, 
                            returnStdout: true
                        ).trim()

                        echo "HTTP Status Code is ${env.WEB_STATUS}"
                    }

                    sh "EOF"
                }
            }
        }

        // stage('Deploy Application') {
        //     when {
        //         environment name: 'WEB_STATUS', value: '200'
        //     }
        //     steps {
        //
        //     }
        // }

        stage ('push to registry'){
            steps{
                sshagent(credentials: [secret]) {
                    sh """ssh -o StrictHostKeyChecking=no ${buildServer} << EOF
                    cd ${directory}
                    echo "docker push ${image}"
                    exit
                    EOF"""
                }
            }
        }

        stage ('deploy'){
            steps{
                sshagent(credentials: [secret]) {
                    sh """ssh -o StrictHostKeyChecking=no ${frontendServer} << EOF
                    cd ~/docker
                    docker compose down
		            docker compose up -d
                    exit
                    EOF"""
                }
            }
        }
    }


    post {
        success {
            discordSend(
                webhookURL: "${env.DISCORD_URL}",
                description: "Click the link to check the jenkins build",
                footer: "Jika anda menerima pesan ini berarti build jenkins tidak ada error",
                link: "https://jenkins.millinov.studentdumbways.my.id/job/wayshub-frontend/",
                result: currentBuild.currentResult,
                title: "Jenkins build for wayshub-frontend has run successfully!"
            )
        }
        failure {
            discordSend(
                webhookURL: "${env.DISCORD_URL}",
                description: "Jenkins build terjadi kegagalan, check build di halaman jenkins",
                footer: "Click the link to check the jenkins build",
                link: "https://jenkins.millinov.studentdumbways.my.id/job/wayshub-frontend/",
                result: currentBuild.currentResult,
                title: "Jenkins build for wayshub-frontend has failed :("
            )
        }
    }
}