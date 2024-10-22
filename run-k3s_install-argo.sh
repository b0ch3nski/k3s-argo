#!/bin/ash
set -euxo pipefail

k3s server --disable=traefik,metrics-server --disable-network-policy --snapshotter=native &
k3s_pid="${!}"
until kubectl get nodes | grep -q Ready; do echo "Waiting for master node"; sleep 1; done

kubectl create namespace argo
kubectl -n argo apply -f "https://github.com/argoproj/argo-workflows/releases/download/${ARGO_VERSION}/quick-start-minimal.yaml"
kubectl -n argo patch service argo-server -p '{"spec": {"type": "LoadBalancer"}}'

# FIXME: wait for resource creation
sleep 60
kubectl wait pod --all-namespaces --all --for=condition=Ready --timeout=600s

kill -SIGINT ${k3s_pid}
wait ${k3s_pid} || true

rm -rfv /.kube /var/log/* /tmp/*
