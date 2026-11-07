locals {
  # Both apps listen on loopback, each on a port of its own.
  port = { homepage = 3000, uptimekuma = 3001 }

  # One tile per app, and one per link. Homepage checks each siteMonitor
  # from the server and shows how fast it answered, or that it's down.
  apps = {
    Apps = [
      { "Uptime Kuma" = {
        href        = "http://127.0.0.1:${local.port.uptimekuma}"
        description = "Is it up?"
        icon        = "uptime-kuma.png"
        siteMonitor = "http://127.0.0.1:${local.port.uptimekuma}"
      } },
    ]
  }
  links = [for name, url in var.links : { (name) = { href = url } }]

  # The Links group only appears when there are links.
  services = concat([local.apps], length(local.links) > 0 ? [{ Links = local.links }] : [])
}

module "uptimekuma" {
  source = "github.com/conn3xorg/circuit-uptimekuma?ref=v0.1.0"

  hosts                = var.hosts
  ssh_user             = var.ssh_user
  ssh_port             = var.ssh_port
  ssh_private_key_file = var.ssh_private_key_file
  ssh_known_hosts_file = var.ssh_known_hosts_file
  ssh_become           = var.ssh_become

  port = local.port.uptimekuma
}

module "homepage" {
  source = "github.com/conn3xorg/circuit-homepage?ref=v0.1.0"

  hosts                = var.hosts
  ssh_user             = var.ssh_user
  ssh_port             = var.ssh_port
  ssh_private_key_file = var.ssh_private_key_file
  ssh_known_hosts_file = var.ssh_known_hosts_file
  ssh_become           = var.ssh_become

  port     = local.port.homepage
  settings = { title = var.title }
  services = local.services
}

circuit "mini_homelab" {
  hosts = var.hosts

  ssh {
    user             = var.ssh_user
    port             = var.ssh_port
    private_key_file = var.ssh_private_key_file
    known_hosts_file = var.ssh_known_hosts_file
    become           = var.ssh_become
  }

  # Whoever logs in sees what runs here and how to reach it.
  step "motd" {
    file {
      path    = "/etc/motd"
      content = <<-EOT
        ${var.title}, set up by Conn3x.
          Homepage     http://127.0.0.1:${local.port.homepage}
          Uptime Kuma  http://127.0.0.1:${local.port.uptimekuma}
        From your laptop: ssh -L ${local.port.homepage}:127.0.0.1:${local.port.homepage} -L ${local.port.uptimekuma}:127.0.0.1:${local.port.uptimekuma} <this host>
      EOT
    }
  }
}
