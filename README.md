## Template Packer para Hyper-V / AlmaLinux 8

# Dependencias
    packer: 1.7.2

&nbsp;


# Instruções para Build

> Para build pelo windows a partir da ISO executar o script **run.ps1** passando os parâmetros ***SSH_PASSWORD***, ***SSH_HOSTNAME***, ***HYPER_VM_NAME***, ***LOGDNA_KEY*** e ***DOCKER_TOKEN*** via linha de comando, exemplo abaixo

    .\run.ps1 -SSH_PASSWORD 'sua_senha' -SSH_HOSTNAME 'partithura.fundimisa' -HYPER_VM_NAME 'almalinux-iso' -LOGDNA_KEY 'logdna_key' -DOCKER_TOKEN 'docker_ey'

&nbsp;
> Apos a build pela ISO para ajustes finais poder ser executado o comando abaixo, lembrando que a ***VM*** criada pelo comando anterior deve estar importada no Hyper-V.

    packer build -force -var-file="var.pkrvars.hcl" -only="hyperv-vmcx.almalinux-8" src
&nbsp;
&nbsp;

