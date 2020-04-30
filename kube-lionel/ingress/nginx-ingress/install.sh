helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm install --namespace lionel nginx-ingress-controller stable/nginx-ingress -f values.yaml
