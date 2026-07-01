variable "network_name" {
  type        = string
  description = "Réseau Docker utilisé par l'infrastructure locale."
  default     = "vsecure-infra"
}

variable "nginx_container_name" {
  type        = string
  description = "Nom du conteneur NGINX CDN local."
  default     = "vsecure-infra-nginx"
}

variable "nginx_port" {
  type        = number
  description = "Port hôte exposant le CDN HLS local."
  default     = 8080
}