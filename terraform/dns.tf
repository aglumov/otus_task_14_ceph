resource "yandex_dns_zone" "otus" {
  name        = "otus-local"
  description = "desc"

  zone             = "otus.local."
  public           = false
  private_networks = [yandex_vpc_network.this.id]
}
