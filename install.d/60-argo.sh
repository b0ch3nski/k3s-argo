kubectl create namespace argo
kubectl -n argo apply -f "https://github.com/argoproj/argo-workflows/releases/download/v${ARGO_VERSION}/quick-start-minimal.yaml"
kubectl -n argo patch service argo-server -p '{"spec": {"type": "LoadBalancer"}}'
