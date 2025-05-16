helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

STACK="kube-prometheus-stack"
CHART="prometheus-community/kube-prometheus-stack"
CHART_VERSION="62.2.1"
NAMESPACE="kube-prometheus-stack"
values="./kube-prometheus-stack-values.yaml"

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --values "$values" \
  --version "$CHART_VERSION"
