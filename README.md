[![Power by Wayarmy](https://raw.githubusercontent.com/wayarmy/kube-useradd/master/Power%20By_%20Wayarmy%20(1).png)](http://rmosolgo.github.io/react-badges/)

# Kubeneretes UserAdd

> This script will help add new user and generate new config file for that user

> This user will be granted privileges to all resources on new namespaces or existing namespaces

### Problems

- With k8s < 1.6, we can't create any user or roles on k8s cluster.
- There is only user admin for k8s cluster managerment.

### Solved

- With k8s 1.6 or above, we have rbac for role binding controller.
- The user will be granted a role. The role contain the permissions with resources per namespaces
- You need to read carefully [RBAC](https://kubernetes.io/docs/admin/authorization/rbac/) for understanding RBAC on kubernetes.

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

with $CACERT and $CAKEY are certificate and key on k8s's master node's pki (`ca.crt` and `ca.key`)

- Grant roles to `existing user` on namespace (with non-exist namespace, namespace will be created)
```
./add-user.sh $USER $NAMESPACE
```

- You can find the ca.crt and ca.key manually:

***If you install k8s cluster by KOPS***
- KOPS will stores the CA key and certificate in its S3 bucket
```
s3://$BUCKET/$CLUSTER/pki/private/ca/$KEY.key
s3://$BUCKET/$CLUSTER/pki/issued/ca/$CERT.crt
```
Download CA key and certificate manually to your local machine:
```
aws s3 cp s3://$BUCKET/$CLUSTER/pki/private/ca/$KEY.key ca.key
aws s3 cp s3://$BUCKET/$CLUSTER/pki/issued/ca/$CERT.crt ca.crt
```


***If you install k8s cluster by KUBEADM***
- KUBEADM will stores CA key and certificate in path: `/etc/kubernetes/pki` on master node. You need to download them to your local machine before run the script.

### Access to k8s cluster with new context
```
export KUBECONFIG=$USER
kubectl run nginx --image=nginx
kubectl get pods
```

### Enjoy your cluster

If you have any questions, please [create new issue](https://github.com/wayarmy/kube-useradd/issues/new)
