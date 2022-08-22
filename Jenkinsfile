pipeline {
  agent none
  stages {
    stage('prisma') {
      steps {
        script {
          pipeline {
            agent {
              docker {
                image 'kennethreitz/pipenv:latest'
                args '-u root --privileged -v /var/run/docker.sock:/var/run/docker.sock'
              }
            }
            stages {
              stage('test') {
                steps {
                  checkout([$class: 'GitSCM', branches: [[name: 'master']], userRemoteConfigs: [[url: 'https://github.com/RadoGar/yelb']]])
                  script {
                    sh """export PRISMA_API_URL=https://api.eu.prismacloud.io
                    pipenv install
                    pipenv run pip install bridgecrew
                    pipenv run bridgecrew --directory . --bc-api-key cf30ea82-a8bf-43b3-a03b-0d84cabaf9ec::MPw+D6RR0S1SqswqdrDTqNFoFZU= --repo-id RadoGar/yelb"""
                  }
                }
              }
            }
            options {
              preserveStashes()
              timestamps()
            }
          }
        }

      }
    }

  }
}