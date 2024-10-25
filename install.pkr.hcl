packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "1.0.11"
    }
  }
}

variables {
  app_name     = "k3s-argo"
  app_version  = "latest"
  argo_version = "master"
}

source "docker" "k3s" {
  image         = "${var.app_name}-repack:${var.app_version}"
  container_dir = "/var/packer"
  pull          = false
  privileged    = true
  commit        = true
}

build {
  name    = var.app_name
  sources = ["source.docker.k3s"]

  provisioner "shell" {
    env = {
      "ARGO_VERSION" = var.argo_version
    }
    script  = "install.sh"
    timeout = "15m"
  }

  post-processor "docker-tag" {
    repository = var.app_name
    tags       = [var.app_version]
  }
}
