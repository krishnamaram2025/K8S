
# Nginx ingress server setup
* Step 1: Clone kubernetes ingress repo
  ```
  git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v3.3.0 && cd kubernetes-ingress/deployments
  ```
* Step 2: SA 
  ```
  kubectl apply -f common/ns-and-sa.yaml
  ```
* Step 3: RBAC 
  ```
  kubectl apply -f rbac/rbac.yaml
  ```
* Step 4: Config
  ```
  kubectl apply -f common/nginx-config.yaml
  ```
* Step 5: Class 
  ```
  kubectl apply -f common/ingress-class.yaml
  ```
* Step 6: Servers 
  ```
  kubectl apply -f common/crds/k8s.nginx.org_virtualservers.yaml
  kubectl apply -f common/crds/k8s.nginx.org_virtualserverroutes.yaml
  kubectl apply -f common/crds/k8s.nginx.org_transportservers.yaml
  kubectl apply -f common/crds/k8s.nginx.org_policies.yaml
  kubectl apply -f common/crds/k8s.nginx.org_globalconfigurations.yaml
  ```
* Step 7: Daemonset 
  ```
  kubectl apply -f daemon-set/nginx-ingress.yaml
  ```
* Step 8: Loadbalancer 
  ```
  kubectl apply -f service/loadbalancer.yaml
  ```
* Step 9: Fetch all services under namespace nginx-ingree
  ```
  kubectl get svc -n nginx-ingress
  ```
* Step 10: Access Nginx LB 
  ```
  MASTER_NODE_IP:80
  ```
  ![image](https://github.com/cloudstonesorg/csp-deployments/assets/112494492/7dd65a71-ec98-4f45-bae3-a75ec4278112)

# Argo CD server setup
* Step 1: Create Namespace argocd
  ```
  kubectl create namespace argocd
  ```
* Step 2: Install Argocd services
  ```
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  ```
* Step 3: Deploy Argo CD service
  ```
  git clone https://github.com/cloudstonesorg/idp-deployments.git &&  cd idp-deployments/argocd && kubectl apply -f service.yml
  ```
* Step 4: Access Argo CD UI
  ```
  kubectl get svc -n argocd
  ```
  ```
  MASTER_NODE_IP:31698
  ```
  ![image](https://github.com/cloudstonesorg/csp-deployments/assets/112494492/f412d5ee-262f-45e1-b140-26d99d0f2f2b)

* Step 5: To fetch default password for admin user
  ```
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"| base64 -d
  ```
* Step 6: Authenticate k8s manifests repo
  ```
  Argo CD UI => Settings => Repositories => Connect Repo => Select HTTPs => fill repo details
  ```
  
# Create secrets to authenticate apps
* Step 1: Create Namespace idp
  ```
  kubectl create namespace idp
  ```
* Step 2: create secrets for idp microservices
  ```
  kubectl create secret generic rest-server-creds --from-literal='DB_SERVER=' --from-literal='DB_USR=' --from-literal='DB_PWD=' --from-literal='GITHUB_USR=' --from-literal='GITHUB_TOKEN=' -n idp
  ```
  ```
  kubectl create secret generic my-gcp-service-account --from-file=key.json=gcp_cred.json
  ```
* Step 3: Create TLS certs
  ```
  kubectl create secret tls internal-apps.cloudstones.org --cert=server.cert --key=server.key -n idp
  ```
* Step 4: docker usernmae and docker password and github token setup in repo secrets at each app repo level to update in idp-deployments repo
  ```
  repo => settings => secrets and varaibles => Actions => repo secret
  ```
* Step 5: Authenticate jfrog docker registry to fetch docker image
  ```
  kubectl create secret docker-registry docker-secret-idp --docker-server="https:IP" --docker-username="" --docker-password="" -n idp
  ```
  
# Not required cause mentioned ubuntu-latest: GitHub Actions self-hosted runner setup
* Step 1: docker install to make runner working
```
https://docs.docker.com/engine/install/debian/
```
* Step 2: Self Hosted Runner setup
```
Go to specific repo => settings => runners => linux
```
* Step 3: Optional: kubectl install if you want to deploy apps using GitHub actions or from the runner manually
```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

# MySQL server setup
```
https://github.com/krishnamaram2025/MySQL
```

# Deployment Apps from Argo CD
```
git clone https://github.com/krishnamaram2025/K8S.git &&  cd K8S/argocd && cat APP_NAME_application.yml
```
```
Argo CD UI => Applications => NEW App => EDIT AS YAML => Create
```
