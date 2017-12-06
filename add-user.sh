#!/bin/bash
# Script add new user for k8s cluster
# Please read README carefully before using this script
# Power by Wayarmy(quanpc294@gmail.com)

set -e
USER=$1
NAMESPACE=$2
CACERT=$3
CAKEY=$4

os_type () {
	case `uname` in
	  Linux )
	     which yum > /dev/null && { echo centos; return; }
	     which zypper > /dev/null && { echo opensuse; return; }
	     which apt-get > /dev/null && { echo debian; return; }
	     ;;
	  Darwin )
	     echo darwin
	     ;;
	esac
}

check_openssl_installed () {
	which openssl > /dev/null && { echo openssl; return; }
}

check_kubectl_installed () {
	which kubectl > /dev/null && { echo kubectl; return; }	
}

show_help () {
	echo "This script will help you create new user on k8s cluster and grant all privileges to resources on k8s cluster's namespace"
	echo "  "
	echo "	Usage: ./add-user.sh ${USER} ${NAMESPACE} ${CA_SERVER_CERT} ${CA_SERVER_KEY}"
	echo "  "
	echo "  Example: ./add-user.sh employee namespace /path/to/ca.crt /path/to/ca.key"
}

if [[ $(check_openssl_installed) != "openssl"  || $(check_kubectl_installed) != "kubectl" ]]
	then
	echo "Both openssl and kubectl must installed on your machine, please install them before run this script"
	exit 1
fi


if [[ $1 == "help" || $1 == "--help" || $1 == "-h" ]]
	then
	show_help
	exit 1
fi


echo "---------Generating namespace--------------------------"
create_ns_if_not_exist () {
	if [[ $(kubectl get ns | awk '{print $1}' | grep -w "$1") != $1 ]]
		then
		kubectl create ns $1
	fi
}
create_ns_if_not_exist $NAMESPACE

echo "  "
echo "  "
echo "  "
echo "  "
echo "---------Generate key context for new user-------------"
mkdir -p key_context
openssl genrsa -out key_context/${USER}.key 2048
openssl req -new -key key_context/${USER}.key -out key_context/${USER}.csr -subj "/CN=${USER}/O=kubernetes"
openssl x509 -req -in key_context/$USER.csr -CA $CACERT -CAkey $CAKEY -CAcreateserial -out key_context/$USER.crt -days 500


echo "  "
echo "  "
echo "  "
echo "  "
echo "  "
echo "---------Register new user to k8s cluster--------------"

cat <<EOF | kubectl create -f -
kind: Role
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  namespace: $NAMESPACE
  name: $USER-role
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
EOF

cat <<EOF | kubectl create -f -
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: $USER-role-binding
  namespace: $NAMESPACE
subjects:
- kind: User
  name: $USER
  apiGroup: ""
roleRef:
  kind: Role
  name: $USER-role
  apiGroup: ""
EOF

echo "  "
echo "  "
echo "  "
echo "  "
echo "  "
echo "---------Generate new config files of $USER -------------"
generate_config_file () {
	CERT_AUTH_DATA=$(cat ~/.kube/config | grep certificate-authority-data | awk -F ': ' '{print $2}')
	SERVER=$(cat ~/.kube/config | grep server | awk -F ': ' '{print $2}')
	CLUSTER_NAME=$(cat ~/.kube/config | grep -C 2 server | grep name | awk -F ': ' '{print $2}')
	if [[ $(os_type) == "darwin" ]]
		then
		CLIENT_CERT_DATA=$(cat key_context/$USER.crt | base64)
		CLIENT_KEY_DATA=$(cat key_context/$USER.key | base64)
	else
		CLIENT_CERT_DATA=$(cat key_context/$USER.crt | base64 -w 0)
		CLIENT_KEY_DATA=$(cat key_context/$USER.key | base64 -w 0)
	fi

	cat <<EOF > $USER
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $CERT_AUTH_DATA
    server: $SERVER
  name: $CLUSTER_NAME
contexts:
- context:
    cluster: $CLUSTER_NAME
    namespace: $NAMESPACE
    user: $USER
  name: $USER-context
current-context: $USER-context
kind: Config
preferences: {}
users:
- name: $USER
  user:
    client-certificate-data: $CLIENT_CERT_DATA
    client-key-data: $CLIENT_KEY_DATA
EOF
}

generate_config_file







