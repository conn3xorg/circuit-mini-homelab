variable "hosts" {
  type        = any
  description = "The homelab server: a map of one name to an address, or to a host object with an address and settings such as host_key."

  validation {
    condition     = can(keys(var.hosts)) && length(var.hosts) == 1 && alltrue([for v in values(var.hosts) : can(tostring(v)) || can(tostring(v.address))])
    error_message = "hosts must be a map of one name to an address, or to an object with an address."
  }
}

variable "ssh_user" {
  type    = string
  default = "root"
}

variable "ssh_port" {
  type    = number
  default = 22
}

variable "ssh_private_key_file" {
  type    = string
  default = null
}

variable "ssh_known_hosts_file" {
  type    = string
  default = null
}

variable "ssh_become" {
  type    = bool
  default = false
}

variable "title" {
  type        = string
  default     = "Homelab"
  description = "The title of Homepage's browser tab, and the first line of the login message."
}

variable "links" {
  type        = map(string)
  default     = {}
  description = "More tiles for Homepage, by name, such as { Router = \"http://192.168.1.1\" }."
}
