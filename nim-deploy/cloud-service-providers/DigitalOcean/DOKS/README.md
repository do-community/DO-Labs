# NVIDIA NIMs on DOKS

This document outlines the process of setting up NVIDIA Inference Microservices (NIMs) on [DigitalOcean Kubernetes Service (DOKS)](https://docs.digitalocean.com/products/kubernetes/reference/gpu-worker-nodes/). NVIDIA NIMs provide pre-optimized container images for both pretrained and customized foundation models, facilitating easy deployment across various architectures (single GPU, multiple GPUs, multi-node GPUs). These microservices are specifically optimized for latency and throughput.

For a comprehensive details of NVIDIA NIMs, refer to the [NVIDIA Developer Center](https://developer.nvidia.com/nim).

![Diagram of the Workflow](https://docs.google.com/drawings/d/1DU8RPP7nsFlWEfhGmlrnjb2mT2bnbOGx_75MDVcEzvI/pub?w=960&h=720)


## Table of Contents

- [Prerequisites](#prerequisites)
- [Observability Setup](#observability-setup)
- [GPU Operator Setup](#gpu-operator-setup)
- [SMB Storage Setup](#smb-storage-setup)
- [Deploy and Test NIM](#deploy-and-test-nim)
  - [Llama3.1 8B](#llama3-8b)
  - [Llama3.1 70B on a sigle node](#deploying-llama31-70b-on-a-single-node)
  - [Llama3.1 70B on multiple nodes](#deploying-llama3-70b-on-multiple-nodes)

## Prerequisites

1. Obtain an [NVIDIA enterprise license](https://build.nvidia.com/explore/discover?signin=true). Verify the license locally by running `docker login nvcr.io`.

2. Gain access to DOKS GPU Early Availability. Sign up through the DigitalOcean cloud console via [Feature Preview](https://cloud.digitalocean.com/account/feature-preview). Note: This requirement will be deprecated in the near future.

3. [Create a DOKS cluster](https://docs.digitalocean.com/products/kubernetes/reference/gpu-worker-nodes/) with H100 GPU(s):
   - For Llama 3.1 8B model: 1x H100 GPU is sufficient
   - For Llama 3.1 70B model: 4x H100 GPUs are recommended
   
   Consult the [NVIDIA NIM support matrix](https://docs.nvidia.com/nim/large-language-models/latest/support-matrix.html) for specific GPU capacity requirements.

4. This tutorial covers both 8B and 70B models. Note that running the 70B model across multiple nodes requires an additional step and has extra requirements (e.g., faster inter-GPU communication).

5. Create a DigitalOcean droplet in the same VPC as your DOKS cluster to host a Samba server. We will utilize the SMB CSI provisioner on DOKS to create a ReadWriteMany storage class. This shared storage is used by NIMs to store the downloaded models.

6. Clone this repo locally where you have setup your kubeconfig for DOKS cluster. It is assumed that you have kubectl and helm installed locally.


## Verify GPU Cards

This optional step allows you to easily check the status of NVIDIA GPUs in your cluster. While `nvidia-smi` is the primary command for NVIDIA GPUs, it needs to be run within a container on the node. By deploying a DaemonSet on GPU nodes, you can quickly access `nvidia-smi` when needed.

> Note: The following file is located in the `1-verify-gpu-cards` directory.

To deploy the CUDA runtime DaemonSet:

```bash
kubectl apply -f 00-cuda-bash.yaml
```

After deployment, you can verify GPU information using the following commands:

1. Check the logs of the CUDA pods:
   ```bash
   kubectl logs ds/cuda-runtime-daemonset
   ```

2. Execute `nvidia-smi` directly in the container:
   ```bash
   kubectl exec -it ds/cuda-runtime-daemonset -- nvidia-smi -L
   ```

This setup provides a convenient way to monitor and verify your GPU resources within the Kubernetes cluster.


## Observability Setup

This section covers the installation of metrics-server and kube-prometheus-stack for cluster monitoring.

> Note: The following files are located in the `2-setup-observability` directory.

### Installation

1. Install metrics-server:
   ```bash
   ./01-metrics-server-install.sh
   ```

2. Install kube-prometheus-stack:
   ```bash
   ./02-kube-prometheus-stack-install.sh
   ```

These scripts use Helm to install the latest upstream versions of the components. You may rerun the script when needing to upgrade by changing the configuration. The kube-prometheus-stack chart is customized to use persistent storage for metrics and includes additional scrape configs for GPU metrics. 

Review the `kube-prometheus-stack-values.yaml` file for the specific configuration being installed.

### Verification

After installation, verify the components are working correctly:

1. Access Grafana:
   ```bash
   kubectl port-forward svc/kube-prometheus-stack-grafana 3000:80 -n kube-prometheus-stack
   ```
   Open `http://localhost:3000` in your browser. Use `admin` for username and `prom-operator` for password. You can customize the password in the helm values file.

2. Access Prometheus:
   ```bash
   kubectl port-forward svc/kube-prometheus-stack-prometheus 9090:9090 -n kube-prometheus-stack
   ```
   Open `http://localhost:9090` in your browser.


## GPU Operator Setup

For those new to NVIDIA GPU Operator, it's helpful to understand its [overview](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html). The GPU Operator is an umbrella component for all NVIDIA Kubernetes GPU management capabilities, including:

- Driver
- Container toolkit
- Kubernetes device plugin
- Node feature discovery
- GPU feature discovery
- MIG manager
- DCGM

The project is maintained as open-source. For more details, refer to the [GPU Operator repository](https://github.com/NVIDIA/gpu-operator) on GitHub.

### Installation

> Note: The following file is located in the `3-install-gpu-operator` directory.

Install the GPU Operator:

```bash
./03-gpu-operator-install.sh
```

Review the `gpu-operator-values.yaml` file for the specific configuration being installed.

### Verification

1. Verify that all components are running:
   ```bash
   kubectl get po -n gpu-operator
   ```

2. Check for appropriate GPU-specific labels on nodes:
   ```bash
   kubectl get node -o json | jq '.items[].metadata.labels'
   ```

3. Verify that MIG (Multi-Instance GPU) is disabled:
   ```bash
   kubectl get node -o json | jq '.items[].metadata.labels' | grep \"nvidia.com/mig.config\"
   ```

   Note: MIG partitioning can be configured by applying labels and patching the cluster-policy.

4. Import the NVIDIA Grafana dashboard:
   - Access your Grafana instance
   - Import dashboard ID 12239 from [Grafana.com](https://grafana.com/grafana/dashboards/12239). Verify the GPU metrics.

5. Check the cluster-policy for GPU Operator component configurations:
   ```bash
   kubectl get clusterpolicies.nvidia.com/cluster-policy --output='json'
   ```

## SMB Storage Setup

We use a DigitalOcean droplet created in the same VPC for setting up a Samba server. Installing and configuring a Samba server is fairly straightforward. We can also configure authentication (user/pass) for remote access.

> Note: The files referenced below are in the directory `4-setup-smb-storage`

### Configure Samba Server

Run the commands in the file `samba-server-on-droplet.sh`. 

At minimum, you will have to modify the volume path that is to be shared. You may want to customize the username/password.

### Setup SMB CSI Provisioner on DOKS

Follow the commands in the `doks-samba-csi.sh` file. 

**Important**: You must change the username and password for the shared folder to whatever you configured in your Samba server configuration.

### Test SMB Share

1. Create the test resources:
   ```bash
   kubectl create -f smb-test.yaml
   ```
2. If pods do not become active and PVC is still not bound, check the SMB controller pod log. Most likely culprit is either:
   - You did not specify credentials, or
   - The path in the storageclass is incorrect.

3. Verify file access across pods:
   ```bash
   kubectl exec smb-test-pod-1 -- cat /mnt/data/testfile2
   kubectl exec smb-test-pod-2 -- cat /mnt/data/testfile1
   ```

4. Clean up test resources:
   ```bash
   kubectl delete -f smb-test.yaml
   ```

### Test Performance

We are primarily interested in sequential r/w, as the shared storage will be used as model store. We use FIO to benchmark the SMB performance.

1. Review the `fio-test.yaml` file.

2. Create the benchmark resources:
   ```bash
   kubectl create -f fio-test.yaml
   ```

3. Check the logs for benchmark results:
   ```bash
   kubectl logs fio-benchmark
   ```

4. Clean up benchmark resources:
   ```bash
   kubectl delete -f fio-test.yaml
   ```

> Note: For a basic 1CPU/2GB droplet with 250GB DO volume, we get around ~218MB/s of sequential read/write performance. This is good enough for our use case (storing model files).



## Deploy and Test NIM

The files referenced in this section are located in the `5-deploy-llama3-nim` and `6-deploy-llama3-70b` directories.

### Common Setup

1. Set up your NGC API key:
   ```bash
   export NGC_API_KEY=<your NGC API key>
   ```

2. Verify your NGC access:
   ```bash
   docker login nvcr.io
   ```

3. Create necessary Kubernetes secrets:
   ```bash
   kubectl create namespace nim
   kubectl -n nim create secret docker-registry registry-secret --docker-server=nvcr.io --docker-username='$oauthtoken' --docker-password=$NGC_API_KEY
   kubectl -n nim create secret generic ngc-api --from-literal=NGC_API_KEY=$NGC_API_KEY
   ```

### Deploying Llama3.1 8B

1. Review the Helm values file for your deployment option. The Helm package is in the `helm/nim-llm` folder of the repository. You will need to adjust the path accordingly for the command to work. Alternately, you can also download the helm chart from [NVCR](https://catalog.ngc.nvidia.com/orgs/nim/helm-charts/nim-llm) and point to that.

2. Deploy using either SMB share or host path as the model store:
   ```bash
   # Using SMB share
   helm --namespace nim install my-nim nim-llm/ -f ./custom-values-SMB.yaml
   
   # Using host path
   helm --namespace nim install my-nim nim-llm/ -f ./custom-values-hostpath.yaml
   ```

3. Verify the model pod is running in the `nim` namespace.

4. Check that the model is being downloaded in the SMB shared folder, e.g.:
   ```
   <smb_share>/<pvc>/ngc/hub/models--nim--meta--llama-3_1-70b-instruct/blobs/
   ```

5. Run Helm test to verify functionality:
   ```bash
   helm -n nim test my-nim --logs
   ```

### Testing Locally

1. Set up port forwarding:
   ```bash
   kubectl -n nim port-forward service/my-nim-nim-llm 8000:8000
   ```

2. Send some test requests:
   ```bash
   # Define the model ID
   # MODEL_ID="meta/llama-3.1-70b-instruct"
   MODEL_ID="meta/llama-3.1-8b-instruct"

   # Fetch the list of models
   curl -X GET 'http://localhost:8000/v1/models'

   # Create a Text Completion
   curl -X POST 'http://localhost:8000/v1/completions' \
      -H "Content-Type: application/json" \
      -d '{
        "model": "'"${MODEL_ID}"'",
        "prompt": "Once upon a time in a land far, far away,",
        "max_tokens": 100,
        "temperature": 0.7,
        "top_p": 0.9,
        "n": 1,
        "stop": ["\n", "."]
      }'

   # Create a chat completion
   curl -X POST 'http://localhost:8000/v1/chat/completions' \
      -H "Content-Type: application/json" \
      -d '{
        "model": "'"${MODEL_ID}"'",
        "messages": [
          {"role": "user", "content": "Hello, how are you today?"}
        ],
        "max_tokens": 150,
        "temperature": 0.7,
        "top_p": 0.9,
        "n": 1,
        "stop": ["\n", "."]
      }'
   ```


Alternatively, you can install an application like [Msty.app](https://msty.app). After installation, add the local model by navigating to **Settings** > **Remote Model Provider**. Click **Add New Provider**, select **OpenAI Compatible Model Provider**, provide a name, set the API endpoint to `http://localhost:8000/v1`, and enter a dummy API key. Then, fetch the available models and add the desired one. You can now chat with the model using the intuitive frontend.


### Performance Testing

1. Create a Triton container:
   ```bash
   kubectl create -f genai-perf-pod.yaml
   ```

2. Run performance test commands inside the Triton container:
   - Execute the commands in `genai-perf-commands.sh`

Sample Benchmark Results for Llama3.1 8B on H100 GPU:
- Output token throughput (per sec): 5543.97
- Request throughput (per sec): 51.46

### Deploying Llama3.1 70B on a Single Node

This deployment requires 4x H100 GPUs. The steps are the same as for Llama3 8B.

Sample Benchmark Results for Llama 2 70B on 4x H100 GPUs (Single Node)
- Output token throughput (per sec): 2342.07
- Request throughput (per sec): 21.17

### Deploying Llama3.1 70B on Multiple Nodes

This example uses 4 individual nodes with 1x H100 each for illustration purposes. Note that you will need accelerated networking between nodes for any reasonable performance.

#### Prerequisites

1. Install LeaderWorkerSet (LWS) API:
   - Follow the installation guide at: https://github.com/kubernetes-sigs/lws/blob/main/docs/setup/install.md

2. Refer to the NVIDIA documentation for multi-node model deployment:
   - https://docs.nvidia.com/nim/large-language-models/latest/deploy-helm.html#multi-node-models

#### Deployment

Deploy Llama3.1 70B across 4x H100 nodes. Note that helm package nim-llm is in helm folder of the repository, so you will need to adjust the paths. Alternately, you can also download the helm chart from [NVCR](https://catalog.ngc.nvidia.com/orgs/nim/helm-charts/nim-llm) and point to that.

```bash
helm --namespace nim install my-nim nim-llm/ -f 6-deploy-llama3-70b/custom-values-SMB.yaml
```





