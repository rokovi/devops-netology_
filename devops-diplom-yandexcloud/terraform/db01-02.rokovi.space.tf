resource "yandex_compute_instance" "db" {
  count                     = "2"
  name                      = "db0${count.index + 1}"
  zone                      = "ru-central1-a"
  hostname                  = "db0${count.index + 1}.rokovi.space"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 4
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu-2004
      name     = "root-db0${count.index + 1}"
      type     = "network-nvme"
      size     = "10"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.private-sub.id
    nat        = false
    ip_address = "192.168.178.${count.index + 13 - 1}"
  }

  metadata = {
    #   ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("./users.txt")}"
  }
}
