# Project Title
This project is implemented to touch and feel of Micro Services architecture with containerized apps

# Infrastructure Set Up
  ```
  https://github.com/krishnamaram2025/Terraform/blob/master/k8s-kubeadm/README.md
  ```

# K8S Cluster setup using kubeadm tool
# On Master nodes
* Step 1: Disable Swap & Add kernel Parameters on all nodes
  ```
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  ```
  ```
  sudo tee /etc/modules-load.d/containerd.conf <<EOF
  overlay
  br_netfilter
  EOF
  sudo modprobe overlay
  sudo modprobe br_netfilter
  ```
  ```
  sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
  net.bridge.bridge-nf-call-ip6tables = 1
  net.bridge.bridge-nf-call-iptables = 1
  net.ipv4.ip_forward = 1
  EOF
  ```
  ```
  sudo sysctl --system
  echo 1 > /proc/sys/net/ipv4/ip_forward
  ```
* Step 2: Install Docker
  ```
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce -y
  ```
* Step 3: Option 1: CRI:Install Dockerd as runtime on all nodes
  ```
  VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')
  echo $VER
  mkdir /tmp/packages
  cd packages/
  wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz
  tar xvf cri-dockerd-${VER}.amd64.tgz
  cp cri-dockerd/cri-dockerd /usr/local/bin/
  cri-dockerd --version
  wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
  wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
  sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
  sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
  systemctl daemon-reload
  systemctl enable cri-docker.service
  systemctl enable --now cri-docker.socket
  systemctl status cri-docker.socket
  ```
* Step 3: Option 2: CRI: Install Containerd as runtime on all nodes
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
* Step 4: Add kubernetes repo on all nodes
  ```
  curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  ```
* Step 5: install kubelet kubeadm kubectl on all nodes
  ```
  sudo apt update
  sudo apt install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
  ```
* Step 6:Install CNI plugins
  ```
  wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
  tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz
  systemctl daemon-reload
  systemctl restart docker
  ```
* Step 7: Initialize Kubernetes Cluster with Kubeadm on master node
  ```
  kubeadm init --cri-soket unix:///var/run/cri-dockerd.sock
  ```
  ```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  ```
* Step 8: copy the above output to join worker node to cluster
  ```
  sudo kubeadm join
  ```
* Step 9: Install Calico Network Plugin
  ```
  kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.25.0/manifests/calico.yaml
  kubectl get pods -n kube-system
  kubectl get nodes
  ```

# On Worker nodes
* Step 1: Disable Swap & Add kernel Parameters on all nodes
  ```
  sudo swapoff -a
  sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
  ```
  ```
  sudo tee /etc/modules-load.d/containerd.conf <<EOF
  overlay
  br_netfilter
  EOF
  sudo modprobe overlay
  sudo modprobe br_netfilter
  ```
  ```
  sudo tee /etc/sysctl.d/kubernetes.conf <<EOF
  net.bridge.bridge-nf-call-ip6tables = 1
  net.bridge.bridge-nf-call-iptables = 1
  net.ipv4.ip_forward = 1
  EOF
  ```
  ```
  sudo sysctl --system
  echo 1 > /proc/sys/net/ipv4/ip_forward
  ```
* Step 2: Install Docker
  ```
  sudo apt-get update
  sudo apt-get install ca-certificates curl gnupg
  sudo install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  sudo apt-get update
  sudo apt-get install docker-ce -y
  ```
* Step 3: Option 1: CRI:Install Dockerd as runtime on all nodes
  ```
  VER=$(curl -s https://api.github.com/repos/Mirantis/cri-dockerd/releases/latest|grep tag_name | cut -d '"' -f 4|sed 's/v//g')
  echo $VER
  mkdir /tmp/packages
  cd packages/
  wget https://github.com/Mirantis/cri-dockerd/releases/download/v${VER}/cri-dockerd-${VER}.amd64.tgz
  tar xvf cri-dockerd-${VER}.amd64.tgz
  cp cri-dockerd/cri-dockerd /usr/local/bin/
  cri-dockerd --version
  wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.service
  wget https://raw.githubusercontent.com/Mirantis/cri-dockerd/master/packaging/systemd/cri-docker.socket
  sudo mv cri-docker.socket cri-docker.service /etc/systemd/system/
  sudo sed -i -e 's,/usr/bin/cri-dockerd,/usr/local/bin/cri-dockerd,' /etc/systemd/system/cri-docker.service
  systemctl daemon-reload
  systemctl enable cri-docker.service
  systemctl enable --now cri-docker.socket
  systemctl status cri-docker.socket
  ```
* Step 3: Option 2: CRI: Install Containerd as runtime on all nodes
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
* Step 4: Add kubernetes repo on all nodes
  ```
  curl -fsSL  https://packages.cloud.google.com/apt/doc/apt-key.gpg|sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/k8s.gpg
  echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
  ```
* Step 5: install kubelet kubeadm kubectl on all nodes
  ```
  sudo apt update
  sudo apt install -y kubelet kubeadm kubectl
  sudo apt-mark hold kubelet kubeadm kubectl
  ```
* Step 6:Install CNI plugins
  ```
  wget https://github.com/containernetworking/plugins/releases/download/v1.1.1/cni-plugins-linux-amd64-v1.1.1.tgz
  tar Cxzvf /opt/cni/bin cni-plugins-linux-amd64-v1.1.1.tgz
  systemctl daemon-reload
  systemctl restart docker
  ```
* Step 7: Initialize Kubernetes Cluster with Kubeadm on master node
  ```
  kubeadm init --cri-soket unix:///var/run/cri-dockerd.sock
  ```
  ```
  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config
  ```
* Step 8: copy the above output to join worker node to cluster
  ```
  sudo kubeadm join
  ```
* Step 9: Install Calico Network Plugin
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
  IP_ADRRESS:30080
  ```

# References
  ```
  https://www.linuxtechi.com/install-kubernetes-on-ubuntu-22-04/
  https://github.com/cloudstones/container-orchestrator/tree/master
  ```
