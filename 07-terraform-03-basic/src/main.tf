provider "yandex" {
  # token     = "${YC_TOKEN}"
  cloud_id  = "b1gr1fstlqic84kol5o2"
  folder_id = "b1g763nq8fffievrt1sb"
  zone      = "ru-central1-b"
}

locals {
#	name = "${terraform.workspace}-instance"

	web_instance_count_map = {
	stage = 1
	prod = 2
 }

    web_instance_type_map = {
	stage = "standard-v1"
	prod  = "standard-v2"}
	
}


resource "yandex_compute_instance" "testvm0703" {
  name                      = "${terraform.workspace}-${count.index}"
#  platform_id 				= var.platform_id
  platform_id				= local.web_instance_type_map[terraform.workspace]
  zone                      = var.zone
  allow_stopping_for_update = true
  count = local.web_instance_count_map[terraform.workspace]
  hostname                  = "${terraform.workspace}-${count.index}"

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
#      image_id = "fd8fte6bebi857ortlja"
	  image_id = var.image_id
	  name     = "root-testvm0702"
      type     = "network-nvme"
      size     = "50"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.sub-1.id
    nat       = true
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

resource "yandex_vpc_network" "net-1" {
  name = "net1"
}

resource "yandex_vpc_subnet" "sub-1" {
  name           = "sub1"
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.net-1.id
  v4_cidr_blocks = ["192.168.78.0/24"]
}
