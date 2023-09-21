# Project Title
This project is implemented to touch and feel of Micro Services architecture with containerized apps

# K8S Cluster setup
```
https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/
```

# Argo CD
```
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
git clone https://github.com/krishnamaram2025/K8S.git && cd argocd
kubectl apply -f service.yml
```

# References
```
https://github.com/cloudstones/container-orchestrator/tree/master
```
