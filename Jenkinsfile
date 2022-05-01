pipeline {
    agent {label "docker-node"} 
    stages {
        stage('Code Checkout') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/spring-projects/spring-petclinic.git']]])
            }
        }
        stage('Build Stage') {
            steps { 
                sh './mvnw package'
            }
        }
        
	 stage('Clone Dockerfile') {
            steps{
		checkout([$class: 'GitSCM', branches: [[name: '*/master']], extensions: [], userRemoteConfigs: [[url: ' https://github.com/ashutoshjha1/petclinic-test.git']]])
            }
			
		}    
	   
        stage('Build Docker Image') {
            steps{
                sh 'sudo docker build -t ashutoshjha/petclinic:v1.0 .'
            }    
          }  
        stage('Docker Login') {
            steps{
		withCredentials([[$class: 'UsernamePasswordMultiBinding', credentialsId: 'e9c9b7ea-3b5a-42df-8e6a-a6f932c52ec5', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD']]) { 
                sh 'sudo docker login -u="${DOCKER_USERNAME}" -p="${DOCKER_PASSWORD}"'
             }  
            }    
          }      
        stage('Publish Docker Image') {
            steps{
                sh 'sudo docker push ashutoshjha/petclinic:v1.0'
            }    
          }   
    }
}
