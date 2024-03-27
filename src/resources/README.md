# Project Title

This project implemented to touch and feel of Micro Services architecture with containerized apps

# Execution Flow

$git clone https://github.com/krishnamaram2/container-orchestrator.git

$cd container-orchestrator/src/mysql

$kubectl create -f mysql-pod.yml

$kubectl create -f mysql-svc.yml

$kubectl create -f mysql-deploy.yml

$cd container-orchestrator/src/flask

$kubectl create -f flask-pod.yml

$kubectl create -f flask-svc.yml

$kubectl create -f flask-deploy.yml
























































Old Info
==================


Single node K8S cluster with kubeadm
=====================================

Step 1: install and setup Constainer Runtime

$yum install -y yum-utils device-mapper-persistent-data lvm2

$yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

$yum update -y && yum install -y containerd.io-1.2.13 docker-ce-19.03.11 docker-ce-cli-19.03.11

$mkdir /etc/docker

$vi daemon.json

{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}

$mkdir -p /etc/systemd/system/docker.service.d


$systemctl daemon-reload
$systemctl restart docker
$sudo systemctl enable docker



Step 2:
==========

## add repo
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-\$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF

# Set SELinux in permissive mode (effectively disabling it)
sudo setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

#install kubeadm,kubectl,kubelet
sudo yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
sudo systemctl enable --now kubelet


step 3: initialize kubeadm
kubeadm init

echo 1 > /proc/sys/net/bridge/bridge-nf-call-iptables(if kubeadm is not working)


step 4:

  mkdir -p $HOME/.kube
  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  sudo chown $(id -u):$(id -g) $HOME/.kube/config

step 5: install pod network weavenet
$vi weavenet.yml
apiVersion: v1
kind: List
items:
  - apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: weave-net
      annotations:
        cloud.weave.works/launcher-info: |-
          {
            "original-request": {
              "url": "/k8s/v1.13/net.yaml",
              "date": "Wed Jul 29 2020 15:43:52 GMT+0000 (UTC)"
            },
            "email-address": "support@weave.works"
          }
      labels:
        name: weave-net
      namespace: kube-system
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRole
    metadata:
      name: weave-net
      annotations:
        cloud.weave.works/launcher-info: |-
          {
            "original-request": {
              "url": "/k8s/v1.13/net.yaml",
              "date": "Wed Jul 29 2020 15:43:52 GMT+0000 (UTC)"
            },
            "email-address": "support@weave.works"
          }
      labels:
        name: weave-net
    rules:
      - apiGroups:
          - ''
        resources:
          - pods
          - namespaces
          - nodes
        verbs:
          - get
          - list
          - watch
      - apiGroups:
          - networking.k8s.io
        resources:
          - networkpolicies
        verbs:
          - get
          - list
          - watch
      - apiGroups:
          - ''
        resources:
          - nodes/status
        verbs:
          - patch
          - update
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: ClusterRoleBinding
    metadata:
      name: weave-net
      annotations:
        cloud.weave.works/launcher-info: |-
          {
            "original-request": {
              "url": "/k8s/v1.13/net.yaml",
              "date": "Wed Jul 29 2020 15:43:52 GMT+0000 (UTC)"
            },
            "email-address": "support@weave.works"
          }
      labels:
        name: weave-net
    roleRef:
      kind: ClusterRole
      name: weave-net
      apiGroup: rbac.authorization.k8s.io
    subjects:
      - kind: ServiceAccount
        name: weave-net
        namespace: kube-system
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: Role
    metadata:
      name: weave-net
      annotations:
        cloud.weave.works/launcher-info: |-
          {
            "original-request": {
              "url": "/k8s/v1.13/net.yaml",
              "date": "Wed Jul 29 2020 15:43:52 GMT+0000 (UTC)"
            },
            "email-address": "support@weave.works"
          }
      labels:
        name: weave-net
      namespace: kube-system
    rules:
      - apiGroups:
          - ''
        resourceNames:
          - weave-net
        resources:
          - configmaps
        verbs:
          - get
          - update
      - apiGroups:
          - ''
        resources:
          - configmaps
        verbs:
          - create
  - apiVersion: rbac.authorization.k8s.io/v1
    kind: RoleBinding
    metadata:
      name: weave-net
      annotations:
        cloud.weave.works/launcher-info: |-
          {
            "original-request": {
              "url": "/k8s/v1.13/net.yaml",
              "date": "Wed Jul 29 2020 15:43:52 GMT+0000 (UTC)"
            },
            "email-address": "support@weave.works"
          }
      labels:
        name: weave-net
      namespace: kube-system
    roleRef:
      kind: Role
      name: weave-net
      apiGroup: rbac.authorization.k8s.io
    subjects:
      - kind: ServiceAccount
        name: weave-net
        namespace: kube-system
  - apiVersion: apps/v1
    kind: DaemonSet
    metadata:
      name: weave-net
      annotations:
        cloud.weave.works/launcher-info: |-
          {
            "original-request": {
              "url": "/k8s/v1.13/net.yaml",
              "date": "Wed Jul 29 2020 15:43:52 GMT+0000 (UTC)"
            },
            "email-address": "support@weave.works"
          }
      labels:
        name: weave-net
      namespace: kube-system
    spec:
      minReadySeconds: 5
      selector:
        matchLabels:
          name: weave-net
      template:
        metadata:
          labels:
            name: weave-net
        spec:
          containers:
            - name: weave
              command:
                - /home/weave/launch.sh
              env:
                - name: HOSTNAME
                  valueFrom:
                    fieldRef:
                      apiVersion: v1
                      fieldPath: spec.nodeName
              image: 'docker.io/weaveworks/weave-kube:2.6.5'
              readinessProbe:
                httpGet:
                  host: 127.0.0.1
                  path: /status
                  port: 6784
              resources:
                requests:
                  cpu: 10m
              securityContext:
                privileged: true
              volumeMounts:
                - name: weavedb
                  mountPath: /weavedb
                - name: cni-bin
                  mountPath: /host/opt
                - name: cni-bin2
                  mountPath: /host/home
                - name: cni-conf
                  mountPath: /host/etc
                - name: dbus
                  mountPath: /host/var/lib/dbus
                - name: lib-modules
                  mountPath: /lib/modules
                - name: xtables-lock
                  mountPath: /run/xtables.lock
            - name: weave-npc
              env:
                - name: HOSTNAME
                  valueFrom:
                    fieldRef:
                      apiVersion: v1
                      fieldPath: spec.nodeName
              image: 'docker.io/weaveworks/weave-npc:2.6.5'
              resources:
                requests:
                  cpu: 10m
              securityContext:
                privileged: true
              volumeMounts:
                - name: xtables-lock
                  mountPath: /run/xtables.lock
          dnsPolicy: ClusterFirstWithHostNet
          hostNetwork: true
          hostPID: true
          priorityClassName: system-node-critical
          restartPolicy: Always
          securityContext:
            seLinuxOptions: {}
          serviceAccountName: weave-net
          tolerations:
            - effect: NoSchedule
              operator: Exists
            - effect: NoExecute
              operator: Exists
          volumes:
            - name: weavedb
              hostPath:
                path: /var/lib/weave
            - name: cni-bin
              hostPath:
                path: /opt
            - name: cni-bin2
              hostPath:
                path: /home
            - name: cni-conf
              hostPath:
                path: /etc
            - name: dbus
              hostPath:
                path: /var/lib/dbus
            - name: lib-modules
              hostPath:
                path: /lib/modules
            - name: xtables-lock
              hostPath:
                path: /run/xtables.lock
                type: FileOrCreate
      updateStrategy:
        type: RollingUpdate


kubectl create -f weavenet.yml

step 6:
kubectl taint nodes --all node-role.kubernetes.io/master-




























Kubernetes installation and set up from scratch
==========================================================



Kubernetes installation and set up with kubeadm
==========================================================


Master



Worker





Step 1: install docker on all machines

https://kubernetes.io/docs/setup/production-environment/container-runtimes/#docker

step 2: install kubeadm,kubecl,kubelet on all machines

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/

Step 3:KUbeadm initialiazation on matser

kubeadm init

$mkdir -p $HOME/.kube

$sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

$sudo chown $(id -u):$(id -g) $HOME/.kube/config

kubeadm join 172.31.87.27:6443 --token 80lvq0.eirhf8w0cmitbtji \
    --discovery-token-ca-cert-hash sha256:52931c998f27892d68c6bd82525f9d3160c680feb6c699d4bc6f92c25d2a9bb7 

step 4: to make execute commands without root user and then execute below commands on Master node

$mkdir -p $HOME/.kube

$sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

$sudo chown $(id -u):$(id -g) $HOME/.kube/config


Step 5: copy form step3 and run on worker node

kubeadm join 172.31.87.27:6443 --token 80lvq0.eirhf8w0cmitbtji \
    --discovery-token-ca-cert-hash sha256:52931c998f27892d68c6bd82525f9d3160c680feb6c699d4bc6f92c25d2a9bb7 


step 6:choose a network drive for pod network  and execute below command on master node

https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/
kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$(kubectl version | base64 | tr -d '\n')"

step 7: on master

kubectl get nodes -o wide

Kubernetes  installation and setup on single node with microk8s
-----------------------------------------------------------------------
https://thenewstack.io/deploy-a-single-node-kubernetes-instance-in-seconds-with-microk8s/

