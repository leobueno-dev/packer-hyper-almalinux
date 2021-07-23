source "hyperv-iso" "almalinux-8" {
  iso_url               = var.iso_url
  iso_checksum          = var.iso_checksum
  boot_command          = var.efi_boot_command
  boot_wait             = var.boot_wait
  generation            = 2
  switch_name           = var.hyperv_switch_name
  cpus                  = var.cpus
  memory                = var.memory
  enable_dynamic_memory = true
  disk_size             = var.disk_size
  disk_block_size       = 1
  headless              = var.headless
  http_directory        = var.http_directory
  vm_name               = var.hyperv_vm_name
  shutdown_command      = var.shutdown_command
  communicator          = "ssh"
  ssh_username          = var.ssh_username
  ssh_password          = var.ssh_password
  ssh_timeout           = var.ssh_timeout
  output_directory      = var.output_directory
}

source "hyperv-vmcx" "almalinux-8" {
  clone_from_vm_name    = var.hyperv_vm_name
  generation            = 2
  switch_name           = var.hyperv_switch_name
  mac_address           = var.hyperv_mac_address
  headless              = var.headless
  cpus                  = var.cpus
  memory                = var.memory
  enable_dynamic_memory = true
  shutdown_command      = var.shutdown_command
  communicator          = "ssh"
  ssh_username          = var.ssh_username
  ssh_password          = var.ssh_password
  ssh_timeout           = var.ssh_timeout
  vm_name               = var.vm_name
}

source "virtualbox-iso" "almalinux-8" {
  iso_url              = var.iso_url
  iso_checksum         = var.iso_checksum
  boot_command         = var.boot_command
  boot_wait            = var.boot_wait
  cpus                 = var.cpus
  memory               = var.memory
  disk_size            = var.disk_size
  http_directory       = var.http_directory
  guest_os_type        = "RedHat_64"
  shutdown_command     = var.shutdown_command
  ssh_username         = var.ssh_username
  ssh_password         = var.ssh_password
  ssh_timeout          = var.ssh_timeout
  hard_drive_interface = "sata"
  vm_name              = var.vm_name
  output_directory     = var.output_directory
  vboxmanage_post      = [
    ["modifyvm", "{{.Name}}", "--memory", var.post_memory],
    ["modifyvm", "{{.Name}}", "--cpus", var.post_cpus]
  ]
}

source "vmware-iso" "almalinux-8" {
  iso_url          = var.iso_url
  iso_checksum     = var.iso_checksum
  boot_command     = var.boot_command
  boot_wait        = var.boot_wait
  cpus             = var.cpus
  memory           = var.memory
  disk_size        = var.disk_size
  headless         = var.headless
  http_directory   = var.http_directory
  guest_os_type    = "centos-64"
  shutdown_command = var.shutdown_command
  ssh_username     = var.ssh_username
  ssh_password     = var.ssh_password
  ssh_timeout      = var.ssh_timeout
  vm_name          = var.vm_name
  vmx_data         = {
    "cpuid.coresPerSocket": "1"
  }
  vmx_data_post    = {
    "memsize": var.post_memory
    "numvcpus": var.post_cpus
  }
  vmx_remove_ethernet_interfaces = true
}