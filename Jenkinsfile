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
        DEPENDENCYTRACK_HOST = 'http://172.20.89.2:8080'
        DEPENDENCYTRACK_API_TOKEN = credentials('dependencychecker')
        DEPENDENCYTRACK_PROJECTNAME = 'discord-bot'
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
                sh '''
                  curl -sS -X PUT "${DEPENDENCYTRACK_HOST}/api/v1/project" \
                    -H "Content-Type: application/json" \
                    -H "X-Api-Key: ${DEPENDENCYTRACK_API_TOKEN}" \
                    -d '{"name":"'"${DEPENDENCYTRACK_PROJECTNAME}"'","version":"current","classifier":"CONTAINER"}'
                '''
                sh "docker run --rm -v /opt/docker/jenkins/jenkins_ws:/home/jenkins/workspace cyclonedx/cyclonedx-dotnet -o ${WORKSPACE} ${WORKSPACE}/source/DiscordBot.sln"
                dependencyTrackPublisher artifact: 'bom.xml', projectName: env.JOB_NAME, projectVersion: env.BUILD_NUMBER, synchronous: false, projectProperties: [isLatest: true, parentName: "${DEPENDENCYTRACK_PROJECTNAME}", tags: ['dotnet']]
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
