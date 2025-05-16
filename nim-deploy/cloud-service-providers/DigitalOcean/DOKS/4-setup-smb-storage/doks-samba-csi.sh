

helm repo add csi-driver-smb https://raw.githubusercontent.com/kubernetes-csi/csi-driver-smb/master/charts
helm repo update

helm upgrade csi-driver-smb csi-driver-smb/csi-driver-smb \
  --namespace kube-system \
  --version v1.15.0 \
  --install

# Create the Secret. Make sure to use your SMB shared drive (Samba) credentials
kubectl create secret generic smbcreds \
  --namespace default \
  --from-literal=username=testuser \
  --from-literal=password=testuser

kubectl apply -f smb-storageclass.yaml
kubectl get storageclass smb


# Run test pods
# kubectl apply -f smb-test.yaml

# If pods do not become active and PVC is still not bound, then check the SMB controller pod log. 
# Most likely culprit is either you did not specify credentials or the path in the storageclass is incorrect.

# kubectl exec smb-test-pod-1 -- cat /mnt/data/testfile2
# kubectl exec smb-test-pod-1 -- cat /mnt/data/testfile1

# kubectl delete -f Scripts_Artifacts/smb-test.yaml


# Read write performance test
# While large model files will be sequential read-write, let us measure both sequential and random access performance.
# kubectl create -f fio-benchmark.yaml
# kubectl logs fio-benchmark

# kubectl delete -f fio-benchmark.yaml

# For a basic 1cpu/2gb droplet with 250GB DO volume, we get around 200MBps+ of sequential read/write performance. This should be good enough for our use case (storing model files).


