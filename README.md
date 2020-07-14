# L1NNA cluster setup

#### kubectl/helm cheatsheet

preset:
```
export KUBECONFIG=$HOME/admin.conf
```

get:
```
kubectl get nodes --show-labels
kubectl get pods --all-namespace
kubectl get pods -n kube-system
kubectl get services
```
proxy/forward:
```
kubectl proxy --address='0.0.0.0'
kubectl port-forward --namespace monitoring service/grafana 3000:8001 (8001=>3000)
```

delete:
```
kubectl delete namespace monitoring
helm delete xxxx --purge
```

dashbord:

http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default
```
kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode

```
