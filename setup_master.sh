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

# enalbe pod deployment on master node: [optional, but needed for our setup]
kubectl taint nodes --all node-role.kubernetes.io/master-

# install helm:
kubectl --namespace kube-system create serviceaccount tiller
kubectl create clusterrolebinding tiller --clusterrole cluster-admin --serviceaccount=kube-system:tiller
helm init --service-account tiller --history-max 100 --wait --upgrade
# the client/serve version may be unsynced. 'upgrade' to remove such possibility

# set docker default runtime to nvidia-runtime (on gpu node)
sudo apt-get install -y jq
jq '."default-runtime"="nvidia"' /etc/docker/daemon.json | sudo tee /etc/docker/daemon.json

# install nvidia device plugin
kubectl create -f https://raw.githubusercontent.com/NVIDIA/k8s-device-plugin/v0.6.0/nvidia-device-plugin.yml

# label node with GPU device
sudo docker info | grep nvidia && kubectl label nodes `kubectl get nodes -o=custom-columns=NAME:.metadata.name | sed -n '1!p'` hardware-type=NVIDIAGPU

# label node with specific GPU model
for pod in `kubectl get pods -n kube-system -o=custom-columns=NAME:.metadata.name | grep nvidia-device-plugin-daemonset`; do
	gpu=$(kubectl exec -it -n kube-system $pod -- nvidia-smi -q | \
		grep 'Product Name' | head -n 1)

	label=$(echo $GPU | cut -d ':' -f 2 | xargs | tr '\r' '')
	label=$(echo ${label// /-})

	node=$(kubectl get pod -n kube-system $pod \
		-o=custom-columns=NODE:.spec.nodeName | tail -n 1)

	kubectl label nodes ${node} "nvidia.com/brand=${label}"
	kubectl label nodes ${node} hardware-type=NVIDIAGPU
done

# list all pods
kubectl get pods -n kube-system

# test run:
kubectl run gpu-test --rm -t -i --restart=Never --image=nvidia/cuda --limits=nvidia.com/gpu=1 nvidia-smi

# done
echo 'finished. you need to manually add export KUBECONFIG=$HOME/admin.conf to your .bashrc to use kubectl'

