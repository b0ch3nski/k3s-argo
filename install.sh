#!/bin/ash
set -euxo pipefail

k3s server --disable=traefik,metrics-server --snapshotter=native --flannel-backend=host-gw &
k3s_pid="${!}"
until kubectl get nodes | grep -q Ready; do echo "Waiting for master node"; sleep 1; done

for script in /tmp/install.d/*.sh; do
  ./${script}
done

# FIXME: wait for resource creation
sleep 60
kubectl wait pod --all-namespaces --all --for=condition=Ready --timeout=600s

kill -SIGINT ${k3s_pid}
wait ${k3s_pid} || true

rm -rfv /.cache /.kube /var/log/* /tmp/*
