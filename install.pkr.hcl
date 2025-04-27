packer {
  required_plugins {
    docker = {
      source  = "github.com/hashicorp/docker"
      version = "1.1.1"
    }
  }
}

variables {
  app_name     = "k3s-argo"
  app_version  = "latest"
  argo_version = "master"
}

source "docker" "k3s" {
  image         = "k3s-ext:${var.app_version}"
  container_dir = "/var/packer"
  pull          = false
  privileged    = true
  commit        = true
}

build {
  name    = var.app_name
  sources = ["source.docker.k3s"]

  provisioner "file" {
    source      = "./install.d"
    destination = "/tmp"
  }

  provisioner "shell" {
    env = {
      "ARGO_VERSION" = var.argo_version
    }
    script  = "install.sh"
    timeout = "30m"
  }

  post-processor "docker-tag" {
    repository = var.app_name
    tags       = [var.app_version]
  }
}
