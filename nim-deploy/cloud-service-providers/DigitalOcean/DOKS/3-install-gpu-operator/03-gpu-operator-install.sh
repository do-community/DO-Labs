helm repo add nvidia https://helm.ngc.nvidia.com/nvidia 
helm repo update

helm upgrade --install --create-namespace \
  gpu-operator nvidia/gpu-operator -f gpu-operator-values.yaml -n gpu-operator

