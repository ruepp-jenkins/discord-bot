properties(
    [
        githubProjectProperty(
            displayName: 'discord-bot',
            projectUrlStr: 'https://github.com/ruepp-jenkins/discord-bot/'
        ),
        disableConcurrentBuilds()
    ]
)

pipeline {
    agent {
        label 'docker'
    }

    environment {
        IMAGE_FULLNAME = 'ruepp/discord-bot'
        DOCKER_API_PASSWORD = credentials('DOCKER_API_PASSWORD')
    }

    triggers {
        cron('30 3 * * 1')
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: env.BRANCH_NAME, url: env.GIT_URL
            }
        }
        stage('DependencyTracker') {
            steps {
                sh 'printenv | sort -h'
                sh "ls -lah ${WORKSPACE}/../"
                sh "ls -lah ${WORKSPACE}"
                sh 'pwd'
                sh "docker run --rm -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace ubuntu ls -lah /home/jenkins/workspace"
                sh "docker run --rm -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace ubuntu ls -lah ${WORKSPACE}"
                sh "docker run --rm -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace cyclonedx/cyclonedx-dotnet -o ${WORKSPACE} ${WORKSPACE}/source/DiscordBot.sln"
                dependencyTrackPublisher artifact: env.WORKSPACE/bom.xml, projectName: env.JOB_NAME, projectVersion: env.BRANCH_NAME, synchronous: true
            }
        }
        stage('Build') {
            steps {
                sh 'chmod +x scripts/*.sh'
                sh './scripts/start.sh'
            }
        }
    }

    post {
        always {
            discordSend result: currentBuild.currentResult,
                description: env.GIT_URL,
                link: env.BUILD_URL,
                title: JOB_NAME,
                webhookURL: DISCORD_WEBHOOK
            // cleanWs()
        }
    }
}
