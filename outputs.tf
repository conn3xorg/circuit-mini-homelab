output "urls" {
  description = "Where each app answers on the server itself. Reach them through an SSH tunnel."
  value = {
    homepage   = module.homepage.url
    uptimekuma = module.uptimekuma.url
  }
}

output "tunnel_ports" {
  description = "The -L arguments for ssh that bring both apps to the same ports on your machine."
  value       = join(" ", [for p in values(local.port) : "-L ${p}:127.0.0.1:${p}"])
}
