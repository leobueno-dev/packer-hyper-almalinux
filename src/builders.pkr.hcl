/*
 * AlmaLinux OS 8 Packer template with Nginx, Docker and Logdna Agent.
 */


build {
  sources = ["sources.hyperv-iso.almalinux-8"]
  
  provisioner "file" {
    destination = "/tmp/logdna.repo"
    source      = "files/logdna.repo"
  }

  provisioner "file" {
    destination = "/tmp/nginx/"
    source      = "files/nginx"
  }

  provisioner "file" {
    destination = "/tmp/id_rsa.tar.gz"
    source      = "files/id_rsa.tar.gz"
  }

  provisioner "file" {
    destination = "/tmp/setup.sh"
    source      = "files/almalinux.install.sh"
  }

  // INSTALAÇÔES
  provisioner "shell" {
    inline = [
      "echo '@> Install dependencies...'",
      "sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo",
      "sudo rpm --import https://repo.logdna.com/logdna.gpg",
      "sudo cp -v -r /tmp/logdna.repo /etc/yum.repos.d/",
      "sudo dnf update -y",
      "sudo dnf install docker-ce docker-ce-cli containerd.io logdna-agent -y",
      "sudo dnf autoremove -y",
      "sudo dnf clean all",
      "sudo systemctl enable nginx",
      "sudo systemctl enable docker",
      "sudo systemctl start nginx",
      "sudo systemctl start docker",
      "sudo usermod -aG docker $USER"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '@> Docker login...'",
      "sudo docker login --username=${var.DOCKER_USER} --password=${var.DOCKER_TOKEN}",
      "sudo docker system info | grep -E 'Username|Registry'",
      "sudo docker pull logdna/logspout:latest"      
    ]
  }

  provisioner "shell" {
    inline = [
      "echo @> CTOP install",
      "sudo wget --quiet https://github.com/bcicen/ctop/releases/download/v0.7.3/ctop-0.7.3-linux-amd64 -O /usr/local/bin/ctop",
      "sudo chmod +x /usr/local/bin/ctop",
      "ctop -v"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '@> Install docker composer...'",
      "sudo curl -L https://github.com/docker/compose/releases/download/1.25.4/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose",
      "sudo chmod +x /usr/local/bin/docker-compose",
      "sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '@> Firewall...'",
      "sudo systemctl start firewalld",
      "sudo systemctl enable firewalld",
      "sudo firewall-cmd --permanent --zone=public --add-service=http --add-service=https",
      "sudo firewall-cmd --reload",
      "sudo firewall-cmd --list-services --zone=public"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo @> Ansible install",
      "pip3 install --user ansible --no-cache-dir"
    ]
  }


  // CONFIGURAÇÕES
  provisioner "shell" {
    inline = [
      "echo '@> Credentials...'",
      "mkdir $HOME/.ssh && mkdir $HOME/tmp",
      "cp /tmp/id_rsa.tar.gz $HOME/tmp/",
      "tar -xf $HOME/tmp/id_rsa.tar.gz -C $HOME/.ssh/",
      "ssh-keyscan -t rsa github.com >> $HOME/.ssh/known_hosts",
      "ssh-keyscan -t rsa bitbucket.org >> $HOME/.ssh/known_hosts",
      "ssh-keyscan -t rsa gitlab.com >> $HOME/.ssh/known_hosts",
      "chmod 600 $HOME/.ssh/id_rsa",
      "chmod 644 $HOME/.ssh/id_rsa.pub",
      "eval `ssh-agent` && ssh-add",
      "chmod 700 $HOME/.ssh",
      "chmod 600 $HOME/.ssh/config",
      "chmod 644 $HOME/.ssh/known_hosts",
      "chown $USER:$USER $HOME/.ssh/",
      "chown $USER:$USER $HOME/.ssh/*",
      "ssh-keygen -l -f $HOME/.ssh/known_hosts"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo @>Make app dir",
      "sudo mkdir -p /app/html",
      "sudo chown -R $USER:$USER /app",
      "cp -v -r /tmp/nginx/html /app/",
      "cp -v /tmp/setup.sh /app/setup.sh",
      "sudo chmod +x /app/setup.sh",
      "sudo chmod +x /app",
      "sudo chmod +x /app/html",
      "sudo chcon -Rt httpd_sys_content_t /app/html"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '@> Configure Nginx...'",
      "sudo chown -R nginx:nginx /app/html",
      "sudo mkdir -p /etc/nginx/sites-available",
      "sudo mkdir -p /etc/nginx/sites-enabled",
      "sudo cp -v -r /tmp/nginx/shared.d /etc/nginx/","sudo cp -v -r /tmp/nginx/shared.d /etc/nginx/",
      "sudo cp -v /tmp/nginx/conf.d/*.conf /etc/nginx/conf.d/",
      "sudo cp -v /tmp/nginx/nginx.conf /etc/nginx/nginx.conf",
      "sudo cp -v /tmp/nginx/default.conf /etc/nginx/sites-available/default.config",
      "sudo ln -s /etc/nginx/sites-available/default.config /etc/nginx/sites-enabled/"
    ]
  }

  provisioner "shell" {
    inline = [
      "echo '@> LogDNA CONFIG...'",
      "cp -v /tmp/setup.sh /app/setup.sh",
      "chmod +x /app/setup.sh",
      "sed -i 's/__LOGDNA_KEY__/${var.logdna_key}/g' /app/setup.sh",
      "sed -i 's/__LOGDNA_TAG__/${var.logdna_tag}/g' /app/setup.sh",
      "sh /app/setup.sh"
    ]
  }

  post-processor "compress" {
    output            = "packer_${var.hyperv_vm_name}_{{.BuilderType}}.tar.gz"
    format            = "tar.gz"
    compression_level = 9
  }

}

build {
  sources = [
    "sources.hyperv-vmcx.almalinux-8"
  ]
}
