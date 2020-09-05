# L1NNA cluster setup

### Setup Master Node

Install GPU driver:
```
curl https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/setup_driver.sh | bash
```
Install Kubernetes stack + Nvidia runtime + monitoring stack:
```
curl https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/setup_master.sh | bash
```
Statically provision persistent volumes (based on each partitions under /media/)
```
curl https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/setup_storage.sh | bash
```
Setup Jupyter hub (this will take a while as we need to compile a new docker image):
```
curl https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/setup_jhub.sh | bash
## debug: kubectl logs $(kubectl get pods -n jhub | grep hub | awk '{print $1;}') -n jhub --follow
```


### Kubectl/Helm Cheatsheet

preset:
```
export KUBECONFIG=$HOME/admin.conf
```

get/describe:
```
kubectl get,describe nodes --show-labels
kubectl get,describe pods --all-namespaces
kubectl get,describe pods -n kube-system
kubectl get,describe services,pv,pvc --all-namespaces
```
proxy/forward:
```
kubectl proxy --address='0.0.0.0'
kubectl port-forward --namespace monitoring service/grafana 8001:3000 (8001=>3000)
```

delete:
```
kubectl delete namespace monitoring
helm delete xxxx --purge
```

dashboard:

http://127.0.0.1:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#/overview?namespace=default
```
kubectl get secret $(kubectl get serviceaccount dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode

```

Local partition setup:
https://help.ubuntu.com/community/InstallingANewHardDrive
```
sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEL
```

### Paritioning:

wipe disk:
```
sudo lsblk -o NAME,FSTYPE,SIZE,MOUNTPOINT,LABEl
sudo wipefs -a /dev/sda
python3 par.py /dev/sdb 4 md
```


### ngnix & https:

ngix server block for reverse proxy:
```
server {
    listen 80;
    server_name yourapp.com; # or server_name subdomain.yourapp.com;

    location / {
        proxy_pass http://localhost:8888;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;

        # Enables WS support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_redirect off;
    }
}
```

https: https://www.digitalocean.com/community/tutorials/how-to-secure-nginx-with-let-s-encrypt-on-ubuntu-20-04
