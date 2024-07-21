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
