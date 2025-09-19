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
        stage('Build') {
            steps {
                sh 'chmod +x scripts/*.sh'
                sh './scripts/start.sh'
            }
        }
        stage('dependencyTrackPublisher') {
            steps {
                dependencyTrackPublisher artifact: env.WORKSPACE, projectName: env.JOB_NAME, projectVersion: env.BUILD_TAG, synchronous: true
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
            cleanWs()
        }
    }
}
