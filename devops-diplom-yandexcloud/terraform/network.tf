
#Create VPC Network
resource "yandex_vpc_network" "rokovi-vpc" {
  name = "rokovi-vpc"
}

#Create subnet
resource "yandex_vpc_subnet" "private-sub" {
  name           = "private-sub"
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.rokovi-vpc.id
  v4_cidr_blocks = ["192.168.178.0/28"]
  route_table_id = yandex_vpc_route_table.nat-table.id
}

#Create gw for private-sub
resource "yandex_vpc_gateway" "nat_gateway" {
  name = "nat-gateway"
  shared_egress_gateway {}
}

#Routing table for Guest VMs
resource "yandex_vpc_route_table" "nat-table" {
  name       = "nat"
  network_id = yandex_vpc_network.rokovi-vpc.id
  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.nat_gateway.id
  }
}


#DNS
resource "yandex_dns_zone" "zone1" {
  name        = "public-zone"
  description = "My first yc public zone"

  labels = {
    label1 = "public"
  }

  zone   = "rokovi.space."
  public = true
}