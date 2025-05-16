helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server
helm repo update

STACK="metrics-server"
CHART="metrics-server/metrics-server"
CHART_VERSION="3.12.1"
NAMESPACE="metrics-server"

helm upgrade "$STACK" "$CHART" \
  --atomic \
  --create-namespace \
  --install \
  --timeout 8m0s \
  --namespace "$NAMESPACE" \
  --version "$CHART_VERSION"