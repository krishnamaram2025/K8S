# Project Title
This project is implemented to touch and feel of Micro Services architecture with containerized apps

# Infrastructure Set Up
```
  https://github.com/krishnamaram2025/Terraform/blob/master/k8s-kubeadm/README.md
```

# K8S Cluster setup
* Step 1: Add kernel Parameters
```
  sudo tee /etc/modules-load.d/containerd.conf <<EOF
  overlay
  br_netfilter
  EOF
  sudo modprobe overlay
  sudo modprobe br_netfilter
  sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
  net.bridge.bridge-nf-call-ip6tables = 1
  net.bridge.bridge-nf-call-iptables = 1
  net.ipv4.ip_forward = 1
  EOF
  sudo sysctl --system
```
* Step 2: Install Containerd runtime on all nodes
```
  sudo apt update
  sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt update
  sudo apt install -y containerd.io
  containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
  sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
  sudo systemctl restart containerd
  sudo systemctl enable containerd
```
* Step 3: Add kubernetes repo on all nodes
```
  curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/kubernetes-xenial.gpg
  sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
```
* Step 4: install kubelet kubeadm kubectl on all nodes
```
  sudo apt update
  sudo apt install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
  echo 1 > /proc/sys/net/ipv4/ip_forward
```
* Step 5: Initialize Kubernetes Cluster with Kubeadm on master node
```
  kubeadm init
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  kubectl cluster-info
  kubectl get nodes
```
* Step 6: Join the worker node to the cluster
```
  sudo kubeadm join k8smaster.example.net:6443 --token vt4ua6.wcma2y8pl4menxh2 \
```
* Step 7: Install Calico Network Plugin
```
  kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
  kubectl get pods -n kube-system
  kubectl get nodes
```
# Argo CD server set up
* Step 1: execute the below commands on master node
```
  kubectl create namespace argocd
  kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
  git clone https://github.com/krishnamaram2025/K8S.git &&  cd K8S/deployments/argocd
  kubectl apply -f service.yml
```
* Step 2: To fetch default password for admin user
```
  kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}"| base64 -d
```
* Step 3: Access Argo CD UI
```
  IP:30080
```

# References
```
https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/
https://github.com/cloudstones/container-orchestrator/tree/master
```
