# Project settings
APP_NAME := k3s-argo
APP_VERSION := $(or $(shell git describe --tags --always),latest)

# Versions
K3S_VERSION := v1.31.1-k3s1
ARGO_VERSION := v3.5.11

# Make settings
.ONESHELL:
.PHONY: run-k3s run-k3s-argo k9s clean repack init fmt test build

# Make goals
run-k3s: ## Runs vanilla K3S testing environment using Docker Compose
	K3S_VERSION="$(K3S_VERSION)" \
	docker compose --file docker-compose-k3s.yml up

run-k3s-argo: ## Runs K3S+Argo testing environment using Docker Compose
	APP_NAME="$(APP_NAME)" \
	APP_VERSION="$(APP_VERSION)" \
	docker compose --file docker-compose-k3s-argo.yml up

k9s: ## Runs K9S terminal-based UI for Kubernetes
	k9s --kubeconfig /tmp/k3s/kubeconfig.yml

clean: ## Removes Docker resources created by this project
	docker compose --file docker-compose-k3s.yml down --volumes
	docker compose --file docker-compose-k3s-argo.yml down --volumes

repack: ## Repackages K3S Docker image to drop unecessary layers and metadata
	docker build \
	--build-arg K3S_VERSION="$(K3S_VERSION)" \
	--label="org.opencontainers.image.title=$(APP_NAME)" \
	--label="org.opencontainers.image.version=$(APP_VERSION)" \
	--label="org.opencontainers.image.revision=$(shell git log -1 --format=%H)" \
	--label="org.opencontainers.image.created=$(shell date --iso-8601=seconds)" \
	--tag="$(APP_NAME)-repack:$(APP_VERSION)" \
	.

init: ## Initializes Packer plugins
	packer init .

fmt: ## Formats Packer templates
	packer fmt .

test: ## Tests Packer templates
	packer validate .

build: repack init ## Builds K3S+Argo final Docker image using Packer
	packer build \
	-var "app_name=$(APP_NAME)" \
	-var "app_version=$(APP_VERSION)" \
	-var "argo_version=$(ARGO_VERSION)" \
	.
