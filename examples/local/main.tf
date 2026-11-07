variable "port" {
  type    = number
  default = 2222
}

module "homelab" {
  source = "../.."

  hosts                = { lab = "127.0.0.1" }
  ssh_port             = var.port
  ssh_private_key_file = "./id_ed25519"
  ssh_known_hosts_file = "./known_hosts"

  title = "My homelab"
  links = { "Conn3x docs" = "https://docs.conn3x.org" }
}

output "urls" {
  value = module.homelab.urls
}

output "tunnel_ports" {
  value = module.homelab.tunnel_ports
}
