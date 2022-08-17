
import groovy.json.JsonSlurper

properties([
    pipelineTriggers([cron('0 22 * * *')])
  ])

podTemplate(
  yaml: """
kind: Pod
apiVersion: v1
metadata:
  labels:
    rasch.dev/jenkinsBuildPod: 'true'
  annotations:
    cluster-autoscaler.kubernetes.io/safe-to-evict: 'false'
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        - labelSelector: # make sure no other build pod is running on the same compute node
            matchExpressions:
              - key: rasch.dev/jenkinsBuildPod
                operator: In
                values:
                  - 'true' 
          topologyKey: kubernetes.io/hostname
  volumes:
    - name: docker-lib
      emptyDir: {}
  containers:
    - name: alpine
      image: 'imagecache.amazeeio.cloud/algmprivsecops/jenkins-compose-lagooncli:v1.1'
      command:
        - cat
      resources:
        requests:
          cpu: 100m
          memory: 200Mi
      securityContext:
        privileged: false
      tty: true
    - name: dindcontainer
      image: 'imagecache.amazeeio.cloud/library/docker:dind'
      args: ["--registry-mirror=https://imagecache.amazeeio.cloud"]
      env:
        - name: DOCKER_TLS_CERTDIR
      resources:
        requests:
          cpu: 12000m
          memory: 24Gi
      volumeMounts:
        - name: docker-lib
          mountPath: /var/lib/docker
      securityContext:
        privileged: true
      tty: true
  nodeSelector:
    lagoon.sh/build: allowed
    lagoon.sh/cpus: "16"
  tolerations:
    - key: lagoon.sh/build
      operator: Exists
      effect: NoSchedule
    - key: lagoon.sh/spot
      operator: Exists
      effect: NoSchedule
""",
    ) {
  node(POD_LABEL) {
   withCredentials([
     usernamePassword(credentialsId: 'rasch-harbor-secret', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME'),
     sshUserPrivateKey(keyFileVariable: "LAGOON_CLI_SSH_KEY_FILE", credentialsId: "rasch-lagoon-cli-ssh"),
     string(credentialsId: 'ras-cleanup-github-api-token', variable: 'GITHUB_API_TOKEN')
     ]) {
        withEnv(['DOCKER_HOST=tcp://localhost:2375', 'CONTAINER_REPO=rasjenkinstest', 'DOCKER_SERVER=harbor-nginx-lagoon-master.ch.amazee.io',
        'PROJECTS=beobachter-k8s-buildperf,handelszeitung-k8s-buildperf,beobachter-k8s,expero-k8s,gaultmillau-k8s,handelszeitung-k8s,schweizer-illustrierte-k8s,streaming-k8s,illustre-k8s,pme-k8s']) {
          stage('Checkout and Setup') {
            container('alpine') {
              checkout scm
              sh 'ls'
              sh 'apk add --no-cache openssh bash jq coreutils'
            }
          }
          stage('Clean Environments') {
            container('alpine') {
                sh """ eval `ssh-agent -s`
                      ssh-add $LAGOON_CLI_SSH_KEY_FILE
                      ./runcleanup.sh
                """
            }
          }
      } //ends withEnv
    } //end withCredentials
  } //end node(label)
} //end podTemplate
