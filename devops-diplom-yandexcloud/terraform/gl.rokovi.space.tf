resource "yandex_compute_instance" "gitlab" {
  name                      = "gitlab"
  zone                      = "ru-central1-a"
  hostname                  = "gitlab.rokovi.space"
  allow_stopping_for_update = true

  resources {
    cores  = 4
    memory = 8
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu-2004
      name     = "root-gitlab"
      type     = "network-nvme"
      size     = "10"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.private-sub.id
    nat        = false
    ip_address = "192.168.178.11"
  }

  metadata = {
    #   ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("./users.txt")}"
  }
}
