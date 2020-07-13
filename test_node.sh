#!/bin/sh
# curl https://raw.githubusercontent.com/L1NNA/L1NNA-cluster/master/test_node.sh | bash


echo 'Testing docker with GPU device'
docker run --gpus all nvidia/cuda:10.0-base nvidia-smi


echo 'Testing GPU pod on the cluster'
kubectl run gpu-test --rm -t -i --restart=Never --image=nvidia/cuda --limits=nvidia.com/gpu=1 nvidia-smi
