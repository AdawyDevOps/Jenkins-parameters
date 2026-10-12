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
    }

    stages {
        stage('Terraform Init') {
            steps {
                echo "Initializing Terraform..."
                sh 'terraform init'
            }
        }

        stage('Terraform Workspace Select') {
            steps {
                echo "Selecting workspace: ${params.ENVIRONMENT}..."
                // الأمر ده بيختار الـ workspace ولو مش موجودة بيعملها create
                sh """
                    terraform workspace select ${params.ENVIRONMENT} || terraform workspace new ${params.ENVIRONMENT}
                """
            }
        }

        stage('Terraform Plan') {
            steps {
                echo "Running Terraform Plan for ${params.ENVIRONMENT}..."
                sh """
                    terraform plan -var-file="${TF_VAR_FILE}" -out="${TF_PLAN_OUT}"
                """
            }
        }

        stage('Manual Approval') {
            steps {
                // هنا البايب لاين هيقف ويستنى قرارك (Approve أو Abort)
                input(
                    id: 'ProceedWithApply',
                    message: "Review the plan above. Do you want to apply changes to [${params.ENVIRONMENT}]?",
                    ok: 'Approve & Apply'
                )
            }
        }

        stage('Terraform Apply') {
            steps {
                echo "Applying changes to ${params.ENVIRONMENT}..."
                // بنطبق نفس الـ plan file اللي تم مراجعته عشان نضمن الأمان
                sh """
                    terraform apply "${TF_PLAN_OUT}"
                """
            }
        }
    }

    post {
        always {
            // تنظيف ملف الـ plan بعد الانتهاء
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
