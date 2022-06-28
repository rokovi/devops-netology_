provider "yandex" {
  # token     = "${YC_TOKEN}"
  cloud_id  = "b1gr1fstlqic84kol5o2"
  folder_id = "b1g763nq8fffievrt1sb"
  zone      = "ru-central1-b"
}

resource "yandex_compute_instance" "testvm0702" {
  name                      = "testvm0702"
  zone                      = "ru-central1-b"
  hostname                  = "testvm0702.netology.cloud"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = "fd8fte6bebi857ortlja"
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

output "internal_ip_address_testvm0702" {
  value = yandex_compute_instance.testvm0702.network_interface.0.ip_address
}

output "external_ip_address_testvm0702" {
  value = yandex_compute_instance.testvm0702.network_interface.0.nat_ip_address
}

