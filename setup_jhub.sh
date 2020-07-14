#!/bin/sh

# make sure kubectl will work
export KUBECONFIG=$HOME/admin.conf


# create storage class


kubectl create -f storageClass.yaml
kubectl create -f persistentVolume.yaml

openssl rand -hex 32


helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
helm repo update

# Suggested values: advanced users of Kubernetes and Helm should feel
# free to use different values.
RELEASE=jhub
NAMESPACE=jhub

helm upgrade --install $RELEASE jupyterhub/jupyterhub \
  --namespace $NAMESPACE  \
  --version=0.9.0 \
  --values config.yaml
# update with changes in config.yaml:
# helm upgrade $RELEASE jupyterhub/jupyterhub --version=0.9.0  --values config.yaml --recreate-pods 

# install jupyter hub




