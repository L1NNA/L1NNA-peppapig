#!/bin/sh
# install driver first, if this is a gpu node: 
# curl https://raw.githubusercontent.com/L1NNA/L1NNA-cluster/master/setup_driver.sh | bash
# then:
# curl https://raw.githubusercontent.com/L1NNA/L1NNA-cluster/master/setup_master.sh | bash
sudo bash -c 'apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update'

sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update

# disable swap on the master node (sorry!, kube requires, supposing kub is the only thing we run on the server)
sudo swapoff -a  
sudo sed -i '/ swap / s/^/#/' /etc/fstab

sudo apt-get install -y --allow-unauthenticated docker.io
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list

sudo apt-get update && sudo apt-get install -y nvidia-docker2

sudo apt-get install -y --allow-unauthenticated kubelet kubeadm kubectl kubernetes-cni
sudo apt-mark hold kubelet kubeadm kubectl

sudo groupadd docker
sudo usermod -aG docker $USER

sudo systemctl enable docker && sudo systemctl start docker
sudo systemctl enable kubelet && sudo systemctl start kubelet

# sudo kubeadm init --apiserver-advertise-address=$1
sudo kubeadm init --pod-network-cidr=10.244.0.0/16
# - kubeadm docs
# There are pod network implementations where the master also plays a role in allocating a set of network address space for each node. 
# When using flannel as the pod network (described in step 3), specify --pod-network-cidr=10.244.0.0/16. 
# This is not required for any other networks besides Flannel.


sudo cp /etc/kubernetes/admin.conf $HOME/
sudo chown $(id -u):$(id -g) $HOME/admin.conf
export KUBECONFIG=$HOME/admin.conf

# fix cid error https://github.com/kubernetes/kubernetes/issues/48798#issuecomment-630397355
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
sudo systemctl restart kubelet

# curl https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/examples/post-install.sh | bash


# install helm:


