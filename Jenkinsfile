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
        node {
            label 'docker'
        }
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
                sh "ls -lah ${WORKSPACE}/source"
                sh 'pwd'
                sh "docker run --rm -v ${PWD}:/ws ubuntu ls -lah /ws/workspace/ruepp_discord-bot_update-dotnet9/"
                sh "docker run --rm -v ${WORKSPACE}:/ws ubuntu ls -lah /ws/"
                sh "docker run --rm -v ${WORKSPACE}:/ws cyclonedx/cyclonedx-dotnet -o /ws /ws/source/DiscordBot.sln"
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
            cleanWs()
        }
    }
}
