# Project Title
This project is implemented to touch and feel of Micro Services architecture with containerized apps

# Pre-Requisites
  ```
  curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
  sudo chmod +x kubectl
  sudo mv kubectl /usr/bin
```

# K8S Cluster set up using Kubeadm 
* Step 1: install docker on all machines
  ```
  git clone https://github.com/krishnamaram2/container-orchestrator.git
  sudo sh container-orchestrator/src/master_worker.sh
  https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker
  ```
* step 2: install kubeadm,kubectl,kubelet on all machines
    ```
    https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
    ```
* Step 3:Kubeadm initialiazation on MASTER
    ```
    kubeadm init
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    kubeadm join 172.31.87.27:6443 --token 80lvq0.eirhf8w0cmitbtji \
        --discovery-token-ca-cert-hash sha256:52931c998f27892d68c6bd82525f9d3160c680feb6c699d4bc6f92c25d2a9bb7
    ```
* Step 4: OPTIONAL : Execute below commands on MASTER to make execute commands without root user
    ```
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
    ```
* Step 5: copy form step3 and run on worker node
    ```
    kubeadm join 172.31.87.27:6443 --token 80lvq0.eirhf8w0cmitbtji --discovery-token-ca-cert-hash sha256:52931c998f27892d68c6bd82525f9d3160c680feb6c699d4bc6f92c25d2a9bb7 
    ```
* Step 6:choose a network drive for pod network  and execute below command on MASTER
    ```
    kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"
    Reference: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
    ```
* Step 7: on master or on sandbox/bastionhost/jumphost
    ```
    curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
    sudo chmod +x kubectl
    sudo mv kubectl /usr/bin
    copy admin.conf from /etc/kubernetes/admin.conf(master node)
    kubectl get nodes -o wide --kubeconfig admin.conf
    ```
* Step 8: Microservices Deployments
  ```
  git clone https://github.com/krishnamaram2/container-orchestrator.git
  cd container-orchestrator/src/flask
  kubectl create -f flask-kubeadm-deployment.yml
  cd container-orchestrator/src/mysql
  kubectl create -f mysql-kubeadm-deployment.yml
  ```

# K8S Cluster set up using Minikube(Note: Install and set up on Local Machine)
* Step 1: Pre-Requisites
  ```
  curl -fsSL https://get.docker.com -o get-docker.sh
  sudo sh get-docker.sh
  sudo systemctl start docker
  sudo usermod -aG docker $(whoami) 
  sudo chmod 666 /var/run/docker.sock
  ```
* Step 2: Setup K8S cluster
  ```
  https://minikube.sigs.k8s.io/docs/start/
  ```
* Step 3: Microservices Deployments
  ```
  git clone https://github.com/krishnamaram2/container-orchestrator.git
  cd container-orchestrator/src/flask
  kubectl create -f flask-kubeadm-deployment.yml
  cd container-orchestrator/src/mysql
  kubectl create -f mysql-kubeadm-deployment.yml
  ```

# K8S Cluster set up using AWS EKS

# K8S Cluster set up using Azure AKS

# K8S Cluster set up using GCP GKE

# K8S Cluster set up in Hardway
