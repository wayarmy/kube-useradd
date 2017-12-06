# Kubeneretes UserAdd

> This script will help add new user and generate new config file for that user

> This user will be granted privileges to all resource on new namespaces or existing namespaces

### Requirements

- Support MacOSX/Ubuntu/Debian or other Linux distro
- kubectl installed and have config file store on `~/.kube/config`
- openssl installed on your machine

### Running

- Follow this step

```
git clone git@github.com:wayarmy/kube-useradd.git
cd kube-useradd
./add-user.sh $USER $NAMESPACE $CACERT $CAKEY
```

with $CACERT and $CAKEY are certificate and key on k8s's master node's pki

- Access to k8s cluster with new context
```
export KUBECONFIG=$USER
kubectl run nginx --image=nginx
kubectl get pods
```

### Enjoy your cluster

If you have any question, please [create new issue](https://github.com/wayarmy/kube-useradd/issues/new)
