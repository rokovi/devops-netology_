resource "yandex_compute_instance" "proxy" {
  name                      = "proxy"
  zone                      = "ru-central1-a"
  hostname                  = "rokovi.space"
  allow_stopping_for_update = true

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.ubuntu-2004
      name     = "root-proxy"
      type     = "network-nvme"
      size     = "10"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.private-sub.id
    nat        = true
    ip_address = "192.168.178.14"
  }


  metadata = {
    #   ssh-keys  = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    user-data = "${file("./users.txt")}"
  }
}
resource "yandex_dns_recordset" "rs1" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "www.rokovi.space."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.proxy.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs2" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "gitlab.rokovi.space."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.proxy.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs3" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "grafana.rokovi.space."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.proxy.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs4" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "prometheus.rokovi.space."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.proxy.network_interface.0.nat_ip_address]
}

resource "yandex_dns_recordset" "rs5" {
  zone_id = yandex_dns_zone.zone1.id
  name    = "alertmanager.rokovi.space."
  type    = "A"
  ttl     = 200
  data    = [yandex_compute_instance.proxy.network_interface.0.nat_ip_address]
}