def secret = 'miral'
def buildServer = 'miral@34.101.172.163'
def frontendServer = 'miral@34.101.210.112'
def directory = '~/project/wayshub-frontend'
def image = 'millinovz/wayshub-frontend:v1'
def branch = 'main'

pipeline{
    agent any
    stages{
        stage ('pulling new code'){
         steps{
             sshagent(credentials: credentials: [secret]) {
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
                    exit
                    EOF"""
                }
            }
        }
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
        environment {
            discord = credentials('DISCORD_WEBHOOK')
        }
        success {
            discordSend(
                webhookURL: "${env.discord}",
                description: "Jenkins Pipeline Build",
                footer: "Footer Text",
                link: env.BUILD_URL,
                result: currentBuild.currentResult,
                title: env.JOB_NAME
            )
        }
        failure {
            discordSend(
                webhookURL: "${env.discord}",
                description: "Jenkins Pipeline Build",
                footer: "Footer Text",
                link: env.BUILD_URL,
                result: currentBuild.currentResult,
                title: env.JOB_NAME
            )
        }
    }
}