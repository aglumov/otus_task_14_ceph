resource "yandex_vpc_network" "this" {
  name = "otus vpc"
}

resource "yandex_vpc_subnet" "yc_subnet" {
  count          = 3
  name           = "otus-subnet-${count.index}"
  v4_cidr_blocks = var.yc_subnets[count.index]
  zone           = var.yc_zones[count.index]
  network_id     = yandex_vpc_network.this.id
  route_table_id = yandex_vpc_route_table.this.id
}

resource "yandex_vpc_gateway" "this" {
  name = "default-gateway"
  shared_egress_gateway {}
}

resource "yandex_vpc_route_table" "this" {
  name       = "main-route-table"
  network_id = yandex_vpc_network.this.id

  static_route {
    destination_prefix = "0.0.0.0/0"
    gateway_id         = yandex_vpc_gateway.this.id
  }
}
