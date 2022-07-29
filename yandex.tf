terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = "ru-central1-a"
}

################################################
# Windows VM
data "yandex_compute_image" "default" {
  family = var.image_family
}

data "template_file" "default" {
  template = file("${path.module}/init.ps1")
  vars = {
    user_name  = var.user_name
    user_pass  = var.user_pass
    admin_pass = var.admin_pass
  }
}

resource "yandex_compute_instance" "default" {
  name     = var.name
  hostname = var.name
  zone     = var.zone
  

  resources {
    cores  = var.cores
    memory = var.memory
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.default.id
      size     = var.disk_size
      type     = var.disk_type
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet0.id
    nat       = var.nat
  }

  metadata = {
    user-data = data.template_file.default.rendered
  }
}
############################################################
# Linux vm
resource "yandex_compute_instance" "vm-1" {
  name = "terraform1"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = "fd80viupr3qjr5g6g9du"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.subnet0.id
    nat       = true
  }

metadata = {
    user-data = "${file("/opt/terraform/yandex/vr.txt")}"
 }


}
############################################################
# Network

resource "yandex_vpc_network" "network0" {
  name = "network0"
}

resource "yandex_vpc_subnet" "subnet0" {
  name           = "subnet0"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.network0.id
  v4_cidr_blocks = ["192.168.10.0/24"]
 }
