pipeline {
  agent any                                    // run on the Jenkins EC2 itself
  environment {                                // variables available to every stage
    AWS_REGION = 'us-east-1'
    ACCOUNT_ID = '481088927422'
    ECR_REPO   = 'backend-api'
    CLUSTER    = 'backend-eks'
    REGISTRY   = "${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
  }
  options {
    timestamps()                               // timestamps in the console log
    disableConcurrentBuilds()                  // two deploys at once would race
    timeout(time: 30, unit: 'MINUTES')         // kill hung builds
  }
  stages {
    stage('Checkout') {
      steps {
        checkout scm                           // clone the repo
        script {
          // unique, traceable tag: build number + short commit (ECR tags are immutable)
          env.IMAGE_TAG = "${env.BUILD_NUMBER}-${sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()}"
        }
      }
    }
    stage('Lint & Test') {
      steps {
        // run inside a throwaway Node container so Jenkins needs no Node install
        sh 'docker run --rm -v "$PWD":/app -w /app node:22-alpine sh -c "npm ci && npm run lint && npm test"'
      }
    }
    stage('Build image') {
      steps { sh 'docker build -t $REGISTRY/$ECR_REPO:$IMAGE_TAG .' }
    }
    stage('Push to ECR') {
      steps {
        sh '''
          aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $REGISTRY
          docker push $REGISTRY/$ECR_REPO:$IMAGE_TAG
        '''                                    // the login token comes from the instance role; no stored keys
      }
    }
    stage('Deploy to EKS') {
      steps {
        sh '''
          aws eks update-kubeconfig --name $CLUSTER --region $AWS_REGION
          kubectl apply -f k8s/configmap.yaml -f k8s/service.yaml -f k8s/ingress.yaml -f k8s/hpa.yaml -f k8s/pdb.yaml
          sed "s|IMAGE_PLACEHOLDER|$REGISTRY/$ECR_REPO:$IMAGE_TAG|" k8s/deployment.yaml | kubectl apply -f -
          if ! kubectl -n backend rollout status deployment/backend-api --timeout=180s; then
            kubectl -n backend rollout undo deployment/backend-api    # automatic rollback on a failed rollout
            exit 1                                                    # mark the build failed
          fi
        '''
      }
    }
  }
  post {
    always { sh 'docker image prune -f || true' }   // keep the Jenkins disk from filling up
  }
}
