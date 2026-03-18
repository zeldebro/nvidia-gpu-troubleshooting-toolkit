# GPU Pod Examples for Kubernetes

Ready-to-use YAML examples for running GPU workloads in Kubernetes.

---

## 1. Basic GPU Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-test
spec:
  restartPolicy: Never
  containers:
  - name: cuda-test
    image: nvidia/cuda:12.2.0-base-ubuntu22.04
    command: ["nvidia-smi"]
    resources:
      limits:
        nvidia.com/gpu: 1
```

```bash
kubectl apply -f gpu-pod.yaml
kubectl logs gpu-test
```

---

## 2. Multi-GPU Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-gpu-pod
spec:
  restartPolicy: Never
  containers:
  - name: multi-gpu
    image: nvidia/cuda:12.2.0-base-ubuntu22.04
    command: ["nvidia-smi"]
    resources:
      limits:
        nvidia.com/gpu: 4
```

---

## 3. GPU Training Job

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: gpu-training-job
spec:
  template:
    spec:
      restartPolicy: OnFailure
      containers:
      - name: training
        image: pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime
        command:
        - python
        - -c
        - |
          import torch
          print(f"CUDA available: {torch.cuda.is_available()}")
          print(f"GPU count: {torch.cuda.device_count()}")
          print(f"GPU name: {torch.cuda.get_device_name(0)}")
          x = torch.randn(1000, 1000, device='cuda')
          y = torch.matmul(x, x)
          print(f"Matrix multiplication on GPU successful: {y.shape}")
        resources:
          limits:
            nvidia.com/gpu: 1
          requests:
            memory: "4Gi"
            cpu: "2"
  backoffLimit: 3
```

---

## 4. GPU Deployment with Health Check

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gpu-inference
spec:
  replicas: 2
  selector:
    matchLabels:
      app: gpu-inference
  template:
    metadata:
      labels:
        app: gpu-inference
    spec:
      containers:
      - name: inference
        image: pytorch/pytorch:2.1.0-cuda12.1-cudnn8-runtime
        command: ["python", "-m", "http.server", "8080"]
        ports:
        - containerPort: 8080
        resources:
          limits:
            nvidia.com/gpu: 1
          requests:
            memory: "4Gi"
            cpu: "2"
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 15
          periodSeconds: 10
```

---

## 5. GPU Pod with Node Selector

Schedule GPU pods on specific nodes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-specific-node
spec:
  nodeSelector:
    nvidia.com/gpu.product: "NVIDIA-A100-SXM4-80GB"
  containers:
  - name: gpu
    image: nvidia/cuda:12.2.0-base-ubuntu22.04
    command: ["nvidia-smi"]
    resources:
      limits:
        nvidia.com/gpu: 1
```

---

## 6. GPU Pod with Tolerations

For nodes with GPU taints:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-toleration-pod
spec:
  tolerations:
  - key: nvidia.com/gpu
    operator: Exists
    effect: NoSchedule
  containers:
  - name: gpu
    image: nvidia/cuda:12.2.0-base-ubuntu22.04
    command: ["nvidia-smi"]
    resources:
      limits:
        nvidia.com/gpu: 1
```

---

## 7. MIG GPU Pod (Multi-Instance GPU)

Request a specific MIG slice:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: mig-pod
spec:
  containers:
  - name: mig-test
    image: nvidia/cuda:12.2.0-base-ubuntu22.04
    command: ["nvidia-smi"]
    resources:
      limits:
        nvidia.com/mig-1g.5gb: 1
```

### Available MIG Profiles (A100 80GB)

| Resource | GPU Memory | GPU Compute |
|----------|-----------|-------------|
| `nvidia.com/mig-1g.5gb` | 5 GB | 1/7 |
| `nvidia.com/mig-1g.10gb` | 10 GB | 1/7 |
| `nvidia.com/mig-2g.10gb` | 10 GB | 2/7 |
| `nvidia.com/mig-3g.20gb` | 20 GB | 3/7 |
| `nvidia.com/mig-4g.40gb` | 40 GB | 4/7 |
| `nvidia.com/mig-7g.80gb` | 80 GB | 7/7 |

---

## 8. GPU CronJob for Periodic Health Check

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: gpu-health-check
spec:
  schedule: "0 */6 * * *"  # Every 6 hours
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: gpu-check
            image: nvidia/cuda:12.2.0-base-ubuntu22.04
            command:
            - /bin/sh
            - -c
            - |
              echo "=== GPU Health Check ==="
              nvidia-smi
              echo "=== Memory ==="
              nvidia-smi --query-gpu=memory.used,memory.total --format=csv
              echo "=== Temperature ==="
              nvidia-smi --query-gpu=temperature.gpu --format=csv
              echo "=== ECC Errors ==="
              nvidia-smi --query-gpu=ecc.errors.uncorrected.volatile.total --format=csv
            resources:
              limits:
                nvidia.com/gpu: 1
```

---

## Verify GPU Access

After deploying any GPU pod:

```bash
# Check pod status
kubectl get pod <pod-name>

# Check if GPU is accessible
kubectl exec -it <pod-name> -- nvidia-smi

# Check pod events for scheduling issues
kubectl describe pod <pod-name>

# Check GPU resource allocation
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\\.com/gpu
```
