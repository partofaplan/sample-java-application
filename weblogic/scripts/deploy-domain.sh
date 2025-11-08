#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

NAMESPACE="weblogic-sample"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DOMAIN_TEMPLATE="${ROOT_DIR}/weblogic/kubernetes/domain.yaml"
CLUSTER_TEMPLATE="${ROOT_DIR}/weblogic/kubernetes/cluster-sample-domain.yaml"
KUBE_DIR="${ROOT_DIR}/.kube"
KUBECONFIG_FILE="${KUBE_DIR}/config"

required_env() {
  local missing=0
  for var in "$@"; do
    if [[ -z "${!var:-}" ]]; then
      echo "Environment variable ${var} must be set." >&2
      missing=1
    fi
  done
  if [[ "${missing}" -eq 1 ]]; then
    exit 1
  fi
}

required_env IMAGE IMAGE_PULL_SECRET_NAME IMAGE_PULL_SECRET_SERVER IMAGE_PULL_SECRET_USERNAME IMAGE_PULL_SECRET_PASSWORD WEBLOGIC_USERNAME WEBLOGIC_PASSWORD RUNTIME_ENCRYPTION_PASSWORD

mkdir -p "${KUBE_DIR}"

if [[ -n "${KUBECONFIG_BASE64:-}" ]]; then
  echo "${KUBECONFIG_BASE64}" | base64 --decode > "${KUBECONFIG_FILE}"
  export KUBECONFIG="${KUBECONFIG_FILE}"
elif [[ -n "${KUBECONFIG_PATH:-}" ]]; then
  cp "${KUBECONFIG_PATH}" "${KUBECONFIG_FILE}"
  export KUBECONFIG="${KUBECONFIG_FILE}"
else
  echo "KUBECONFIG_BASE64 or KUBECONFIG_PATH must be provided so kubectl can reach the cluster." >&2
  exit 1
fi

kubectl apply -f "${ROOT_DIR}/weblogic/kubernetes/namespace.yaml"

kubectl apply -f "${CLUSTER_TEMPLATE}"

kubectl -n "${NAMESPACE}" create secret generic weblogic-credentials \
  --from-literal=adminUserName="${WEBLOGIC_USERNAME}" \
  --from-literal=adminPassword="${WEBLOGIC_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret generic runtime-encryption-secret \
  --from-literal=password="${RUNTIME_ENCRYPTION_PASSWORD}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl -n "${NAMESPACE}" create secret docker-registry "${IMAGE_PULL_SECRET_NAME}" \
  --docker-server="${IMAGE_PULL_SECRET_SERVER}" \
  --docker-username="${IMAGE_PULL_SECRET_USERNAME}" \
  --docker-password="${IMAGE_PULL_SECRET_PASSWORD}" \
  --docker-email="noreply@example.com" \
  --dry-run=client -o yaml | kubectl apply -f -

export IMAGE
export IMAGE_PULL_SECRET_NAME

envsubst < "${DOMAIN_TEMPLATE}" | kubectl apply -f -

echo "Model in Image deployment applied. Monitor the operator and pod logs to verify rollout."
