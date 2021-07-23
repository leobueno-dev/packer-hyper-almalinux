param ($SSH_PASSWORD, $SSH_HOSTNAME, $HYPER_VM_NAME, $LOGDNA_KEY, $DOCKER_TOKEN)

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
echo "@>Coping files"
cp http\almalinux-8.inst.ks.example http\almalinux-8.inst.ks
cp var.pkrvars.hcl.example var.pkrvars.hcl


echo "@>Update Variaveis de usuário"
(Get-Content http\almalinux-8.inst.ks).replace('<SSH_PASSWORD>',$SSH_PASSWORD) | Set-Content http\almalinux-8.inst.ks
(Get-Content http\almalinux-8.inst.ks).replace('<SSH_HOSTNAME>',$SSH_HOSTNAME) | Set-Content http\almalinux-8.inst.ks
(Get-Content var.pkrvars.hcl).replace('<SSH_PASSWORD>',$SSH_PASSWORD) | Set-Content var.pkrvars.hcl
(Get-Content var.pkrvars.hcl).replace('<HYPER_VM_NAME>',$HYPER_VM_NAME) | Set-Content var.pkrvars.hcl
(Get-Content var.pkrvars.hcl).replace('<LOGDNA_KEY>',$LOGDNA_KEY) | Set-Content var.pkrvars.hcl
(Get-Content var.pkrvars.hcl).replace('<DOCKER_TOKEN>',$DOCKER_TOKEN) | Set-Content var.pkrvars.hcl

echo "@> Run packer Build"

packer build -var-file="var.pkrvars.hcl" -force -only="hyperv-iso.almalinux-8" src


echo "@>FINISHED"