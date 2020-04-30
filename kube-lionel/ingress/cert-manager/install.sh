kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.12/deploy/manifests/00-crds.yaml
helm repo add jetstack https://charts.jetstack.io
helm install  --namespace lionel --version v0.12.0 cert-manager jetstack/cert-manager
