variables {
  //
  // common variables
  //
  iso_url                  = "http://repo.almalinux.org/almalinux/8.4/isos/x86_64/AlmaLinux-8.4-x86_64-boot.iso"
  iso_checksum             = "file:http://repo.almalinux.org/almalinux/8.4/isos/x86_64/CHECKSUM"
  headless                 = true
  boot_wait                = "5s"
  cpus                     = 4
  memory                   = 2048
  post_cpus                = 2
  post_memory              = 2048
  http_directory           = "http"
  root_shutdown_command    = "/sbin/shutdown -hP now"
  output_directory         = ""
  vm_name                  = "almalinux8"

  boot_command     = [
    "<tab> text ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux-8.inst.ks<enter><wait>"
  ]
  efi_boot_command = [
    "e<down><down><end><bs><bs><bs><bs><bs>text inst.ks=http://{{ .HTTPIP }}:{{ .HTTPPort }}/almalinux-8.inst.ks<leftCtrlOn>x<leftCtrlOff>"

  ]
  disk_size        = 30000
  shutdown_command = "echo partithura | sudo -S /sbin/shutdown -hP now"
  
  ssh_username     = "partithura"
  ssh_password     = null
  ssh_timeout      = "3600s"
  // exemplo de execução para passar a senha por parametro
  // packer build -force -only="hyperv-vmcx.almalinux-8" .
  
  //
  // /hyper-v specific variables
  //

  hyperv_switch_name       = "packer"
  // hyperv_switch_name       = "packer"
  hyperv_vm_name           = null 
  hyperv_mac_address       = "00155d010a22"
  
}


variable "DOCKER_TOKEN" {
  type        = string
  description = "DockerHub Token"
  default     = null
}

variable "DOCKER_USER" {
  type        = string
  description = "DockerHub Username"
  default     = "partithurati"
}

variable "logdna_key" {
  type        = string
  description = "LogDNA key"
  default     = null
}
