terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "vsecure" {
  name = var.network_name
}

resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_container" "nginx" {
  name     = var.nginx_container_name
  image    = docker_image.nginx.image_id
  must_run = true
  restart  = "unless-stopped"

  ports {
    internal = 80
    external = var.nginx_port
  }

  networks_advanced {
    name = docker_network.vsecure.name
  }

  volumes {
    host_path      = abspath("${path.module}/../../media/hls")
    container_path = "/app/media/hls"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/../../media/uploads")
    container_path = "/app/media/uploads"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/../../media/keys")
    container_path = "/app/media/keys"
    read_only      = true
  }

  volumes {
    host_path      = abspath("${path.module}/../nginx/nginx.conf")
    container_path = "/etc/nginx/nginx.conf"
    read_only      = true
  }
}