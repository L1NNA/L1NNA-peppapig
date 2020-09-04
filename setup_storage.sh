#!/bin/sh
# curl https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/setup_storage.sh | bash
# make sure kubectl will work
export KUBECONFIG=$HOME/admin.conf


echo 'setting up storage class'
kubectl create -f https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/local-hdd-lg.yaml
kubectl create -f https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/local-hdd-md.yaml
kubectl create -f https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/local-hdd-sm.yaml

echo 'setting up PV according to the volums at /media/'
for D in /media/sm/*; do
    if [ -d "${D}" ]; then
        par="${D}"
        name='v'${par//"/"/"-"}
        size=$(sudo df -BG --output=avail $par| grep -v Avail | xargs)
        echo $par "=>" $name $size "bytes"   
        patch1='{"metadata":{"name":"'$name'"},"spec":{"capacity":{"storage":"'$size'i"}, "storageClassName":"local-hdd-sm", "local":{"path":"'$par'"},"nodeAffinity":{"required":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/hostname","operator":"In","values":["'$(hostname)'"]}]}]}}}}}'
        kubectl patch -f https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/local-hdd-pv.yaml -p $patch1 --dry-run=client -o yaml | kubectl create -f -
        # kubectl create -f local-hdd-pv.yaml
        echo $patch1
        # break
    fi
done

echo 'setting up PV according to the volums at /media/'
for D in /media/md/*; do
    if [ -d "${D}" ]; then
        par="${D}"
        name='v'${par//"/"/"-"}
        size=$(sudo df -BG --output=avail $par| grep -v Avail | xargs)
        echo $par "=>" $name $size "bytes"   
        patch1='{"metadata":{"name":"'$name'"},"spec":{"capacity":{"storage":"'$size'i"}, "local":{"path":"'$par'"},"nodeAffinity":{"required":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/hostname","operator":"In","values":["'$(hostname)'"]}]}]}}}}}'
        kubectl patch -f https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/local-hdd-pv.yaml -p $patch1 --dry-run=client -o yaml | kubectl create -f -
        # kubectl create -f local-hdd-pv.yaml
        echo $patch1
        # break
    fi
done


echo 'setting up PV according to the volums at /media/'
for D in /media/lg/*; do
    if [ -d "${D}" ]; then
        par="${D}"
        name='v'${par//"/"/"-"}
        size=$(sudo df -BG --output=avail $par| grep -v Avail | xargs)
        echo $par "=>" $name $size "bytes"   
        patch1='{"metadata":{"name":"'$name'"},"spec":{"capacity":{"storage":"'$size'i"}, "storageClassName":"local-hdd-lg", "local":{"path":"'$par'"},"nodeAffinity":{"required":{"nodeSelectorTerms":[{"matchExpressions":[{"key":"kubernetes.io/hostname","operator":"In","values":["'$(hostname)'"]}]}]}}}}}'
        kubectl patch -f https://raw.githubusercontent.com/L1NNA/L1NNA-peppapig/master/local-hdd-pv.yaml -p $patch1 --dry-run=client -o yaml | kubectl create -f -
        # kubectl create -f local-hdd-pv.yaml
        echo $patch1
        # break
    fi
done

