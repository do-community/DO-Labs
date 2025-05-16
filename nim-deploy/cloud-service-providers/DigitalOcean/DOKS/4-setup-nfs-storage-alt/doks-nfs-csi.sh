
# Ref: https://github.com/kubernetes-csi/csi-driver-nfs/tree/master/charts
helm repo add csi-driver-nfs https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts
helm install csi-driver-nfs csi-driver-nfs/csi-driver-nfs --namespace kube-system --version v4.9.0

kubectl apply -f nfs-storageclass.yaml
kubectl get storageclass nfs-client

# Run test pods
kubectl apply -f nfs-test.yaml

# If pods do not become active and PVC is still not bound, then check the SMB controller pod log. 
# Most likely culprit is either you did not specify credentials or the path in the storageclass is incorrect.
kubectl exec smb-test-pod-1 -- cat /mnt/data/testfile2
kubectl exec smb-test-pod-1 -- cat /mnt/data/testfile1

kubectl delete -f Scripts_Artifacts/smb-test.yaml


# Read write performance test
# While large model files will be sequential read-write, let us measure both sequential and random access performance.
kubectl create -f fio-test-nfs.yaml
kubectl logs fio-benchmark

kubectl delete -f fio-test-nfs.yaml

For a basic 1cpu/2gb droplet with 250GB DO volume, we get around 200MBps+ of sequential read/write performance. This should be good enough for our use case (storing model files).

