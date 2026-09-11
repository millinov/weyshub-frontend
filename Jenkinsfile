def secret = 'jenkins-miralssh'
def testLink = 'http://localhost:3000'
def directory = '~/project/wayshub-frontend'
def image = 'millinovz/wayshub-frontend:v1'
def branch = 'main'

pipeline{
    agent any
    
    environment {
        DISCORD_URL = credentials('DISCORD_WEBHOOK')
        USER_FRONTEND = credentials('USER_FRONTEND')
        USER_BUILD = credentials('USER_BUILD')
    }

    stages{

        stage ('pulling new code'){
         steps{
             sshagent(credentials: [secret]) {
                    sh """ssh -o StrictHostKeyChecking=no ${env.USER_BUILD} << EOF
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
                    sh """ssh -o StrictHostKeyChecking=no ${env.USER_BUILD} << EOF
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
                sshagent(credentials: [secret]) {
                    script {
                        sleep 15
                        def command = """ssh -o StrictHostKeyChecking=no ${env.USER_BUILD} 'curl -s -o /dev/null -w "%{http_code}" http://localhost:3000'"""

                        def webStatus = sh(
                            script: command,
                            returnStdout: true
                        ).trim()

                        echo webStatus

                        if (webStatus != '200') {
                            error "Application test failed! HTTP Status: " + webStatus
                        }

                        echo "Application is running successfully!"
                    }
                }
            }
        }

        stage ('push to registry'){
            steps{
                sshagent(credentials: [secret]) {
                    sh """ssh -o StrictHostKeyChecking=no ${env.USER_BUILD} << EOF
                    cd ${directory}
                    docker compose down
                    docker push ${image}
                    echo "docker push ${image}"
                    exit
                    EOF"""
                }
            }
        }

        stage ('deploy'){
            steps{
                sshagent(credentials: [secret]) {
                    sh """ssh -o StrictHostKeyChecking=no ${env.USER_FRONTEND} << EOF
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
                description: "Click the link to check the jenkins build 1",
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