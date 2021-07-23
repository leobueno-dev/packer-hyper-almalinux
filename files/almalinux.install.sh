#!/usr/bin/bash

OPTIND=1
ENV=$1
LOGDNA_KEY=__LOGDNA_KEY__
LOGDNA_TAG=__LOGDNA_TAG__

setupSwap () {
  echo '@> Swap setup [start]' && \
  sudo fallocate -l 2G /swapfile && \
  sudo chmod 600 /swapfile && \
  sudo mkswap /swapfile && \
  sudo swapon /swapfile && \
  sudo swapon --show && \
  sudo sysctl vm.swappiness=40 && \
  echo 'vm.swappiness=40' | sudo tee -a /etc/sysctl.conf && \
  echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
  echo '@> Swap setup [end]'
}

setupOps () {
  echo '@> OPS setup [start]' && \
  echo "@>> Cloning ops project..." && \
  git clone --depth 1 git@bitbucket.org:partithura/partithura-infra.git /app/ops && \
  cd /app/ops && \
  echo "@>> Creating staging config..." && \
  cp ansible/inventory/staging.ini.example ansible/inventory/staging.ini && \
  sed -i 's/<staging_ip>/127.0.0.1 ansible_connection=local/g' ansible/inventory/staging.ini
  echo '@> OPS setup [end]'
}

hostInfo () {
  echo "@> Host: $(hostname)" && \
  sudo sed -i "s/__HOSTNAME__/$(hostname)/g" /app/html/index.html
}

logDNA () {
  sudo logdna-agent -k ${LOGDNA_KEY} && \
  sudo logdna-agent -t agent,${LOGDNA_TAG} && \
  sudo logdna-agent --hostname $(hostname) && \
  sudo chkconfig logdna-agent on
  sudo service logdna-agent start
  sudo docker run --name='logdna' --restart=always \
    -d -v=/var/run/docker.sock:/var/run/docker.sock \
    -e HOSTNAME="$(hostname).docker" \
    -e LOGDNA_KEY="${LOGDNA_KEY}" \
    -e TAGS="${ENV},docker" \
    logdna/logspout:latest
}

commonTasks () {
  setupSwap && hostInfo && logDNA
}

echo $ENV
echo $LOGDNA_KEY

commonTasks


# case $ENV in
#   production)
#   productionSetup
#   ;;
#   staging)
#   stagingSetup
#   ;;
#   *)
#   echo "Unknown env $ENV" && ENV=UNKNOWN && commonTasks
#   ;;
# esac