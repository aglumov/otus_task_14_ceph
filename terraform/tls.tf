resource "tls_private_key" "ceph-key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
