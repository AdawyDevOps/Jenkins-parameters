pipeline {
    agent any

    parameters {
        choice(
            name: 'ENVIRONMENT',
            choices: ['dev', 'stage', 'prod'],
            description: 'Select the target deployment environment'
        )
    }

    environment {
        TF_VAR_FILE = "environments/${params.ENVIRONMENT}.tfvars"
        TF_PLAN_OUT = "tfplan-${params.ENVIRONMENT}"
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {
        stage('Terraform Operations') {
            steps {
                // هنا يتم تفعيل واستخدام الكريدينشالز
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        echo "Initializing Terraform..."
                        terraform init

                        echo "Selecting workspace: ${ENVIRONMENT}..."
                        terraform workspace select ${ENVIRONMENT} || terraform workspace new ${ENVIRONMENT}

                        echo "Running Terraform Plan..."
                        terraform plan -var-file="${TF_VAR_FILE}" -out="${TF_PLAN_OUT}"
                    '''
                }
            }
        }

        stage('Manual Approval') {
            steps {
                input(
                    id: 'ProceedWithApply',
                    message: "Review the plan above. Do you want to apply changes to [${params.ENVIRONMENT}]?",
                    ok: 'Approve & Apply'
                )
            }
        }

        stage('Terraform Apply') {
            steps {
                // وهنا أيضاً يتم استخدامها لتنفيذ الـ Apply على AWS
                withCredentials([
                    string(credentialsId: 'aws-access-key-id', variable: 'AWS_ACCESS_KEY_ID'),
                    string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')
                ]) {
                    sh '''
                        echo "Applying changes to ${ENVIRONMENT}..."
                        terraform apply "${TF_PLAN_OUT}"
                    '''
                }
            }
        }
    }

    post {
        always {
            sh "rm -f ${TF_PLAN_OUT}"
        }
        success {
            echo "Terraform applied successfully to ${params.ENVIRONMENT}!"
        }
        failure {
            echo "Terraform pipeline failed!"
        }
        aborted {
            echo "Deployment was aborted by user."
        }
    }
}
