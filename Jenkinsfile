pipeline {
 agent any
 
 stages {
 stage(‘checkout’) {
 steps {
 git branch: ‘master’, url: ‘git@https://github.com/ankababug/prod.git’
 
 }
 }
 
 stage(‘Provision infrastructure’) {
 
 steps {
 {
 sh ‘/usr/bin/terraform init’
 sh ‘/usr/bin/terraform plan -out=plan’
 sh ‘/usr/bin/terraform apply plan’
 }
}
} 
}
}

