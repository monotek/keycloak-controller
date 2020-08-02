#!/bin/sh
#
# lint bash scripts
#

set -o errexit

HELM_VERSION="3.2.4"
KEYCLOAK_CHART_VERSION="${1}"
KEYCLOAK_CONTROLLER_CHART_VERSION="${2}"
NAMESPACE="keycloak"

# install kubectl
apt update
apt dist-upgrade -y
apt install -y kubectl

kubectl get nodes
exit 0

# install helm
curl --silent --show-error --fail --location --output get_helm.sh https://raw.githubusercontent.com/kubernetes/helm/master/scripts/get
chmod 700 get_helm.sh
./get_helm.sh --version "${HELM_VERSION}"
rm get_helm.sh

# add helm repos
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add codecentric https://codecentric.github.io/helm-charts
helm repo add kiwigrid https://kiwigrid.github.io

# update helm repos
helm repo update

# create keycloak namespace
kubectl create namespace "${NAMESPACE}"

# install keycloak
helm upgrade -i keycloak codecentric/keycloak --namespace "${NAMESPACE}" --version "${KEYCLOAK_CHART_VERSION}"

# install keycloak-controller
helm upgrade -i keycloak kiwigrid/keycloak-controller --namespace "${NAMESPACE}" --version "${KEYCLOAK_CONTROLLER_CHART_VERSION}" --set fullnameOverride=keycloak-controller --set javaToolOptions="-XX:+ExitOnOutOfMemoryError"

 