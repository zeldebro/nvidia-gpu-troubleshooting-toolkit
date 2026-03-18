# Kubernetes GPU Operator Debugging Guide

The NVIDIA GPU Operator automates management of GPU drivers, device plugins, monitoring, and related components in Kubernetes.

It installs and manages:

- GPU drivers
- NVIDIA container toolkit
- NVIDIA device plugin
- DCGM exporter
- MIG manager

---

## Check GPU Nodes

Verify that Kubernetes nodes have GPUs available.

```bash
kubectl describe node
```

Look for:

```text
nvidia.com/gpu
```

Example:

```text
Capacity:
  nvidia.com/gpu: 4
```

This means the node has 4 GPUs.

---

## Check GPU Operator Pods

```bash
kubectl get pods -n gpu-operator
```

Expected components:

| Pod | Purpose |
| ---- | ---- |
| nvidia-driver | Installs GPU driver on nodes |
| nvidia-device-plugin | Exposes GPUs to Kubernetes |
| dcgm-exporter | Exports GPU metrics |
| nvidia-container-toolkit | Enables containers to use GPUs |
| mig-manager | Manages MIG GPU partitioning |

Example:

```text
NAME                              STATUS
nvidia-driver-daemonset           Running
nvidia-device-plugin-daemonset    Running
dcgm-exporter                     Running
```

---

## Verify GPU Access Inside Pod

Example GPU pod resource configuration:

```yaml
resources:
  limits:
    nvidia.com/gpu: 1
```

Deploy pod and check GPU access.

Inside pod:

```bash
nvidia-smi
```

Example output:

```text
+-----------------------------------------------------------------------------+
| NVIDIA-SMI 580.82       Driver Version: 580.82       CUDA Version: 13.0     |
+-----------------------------------------------------------------------------+
```

---

## Check GPU Metrics (DCGM)

DCGM exporter provides GPU metrics for Prometheus.

Port-forward metrics endpoint:

```bash
kubectl port-forward svc/dcgm-exporter 9400
```

Open metrics endpoint:

```text
http://localhost:9400/metrics
```

Example metrics:

```text
DCGM_FI_DEV_GPU_UTIL
DCGM_FI_DEV_MEM_COPY_UTIL
DCGM_FI_DEV_POWER_USAGE
DCGM_FI_DEV_GPU_TEMP
```

---

## Check MIG Configuration

Check MIG status:

```bash
nvidia-smi -mig 1
```

List MIG profiles:

```bash
nvidia-smi -mig -lgip
```

Create MIG instances:

```bash
nvidia-smi -mig -cgi 19,19
```

---

## Common GPU Operator Issues

### GPU Not Detected

Check GPU driver:

```bash
ls /proc/driver/nvidia
```

Check node GPU resources:

```bash
kubectl describe node
```

### Device Plugin Not Running

Restart device plugin:

```bash
kubectl rollout restart daemonset nvidia-device-plugin
```

### GPU Pods Stuck in Pending

Check pod description:

```bash
kubectl describe pod <pod-name>
```

Possible error:

```text
Insufficient nvidia.com/gpu
```

Meaning: cluster does not have available GPUs.

---

## Useful Commands

Check GPU resources in cluster:

```bash
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\.com/gpu
```

Check GPU pods:

```bash
kubectl get pods -A | grep gpu
```

Check GPU metrics:

```bash
kubectl logs dcgm-exporter
```

---

## Debug Workflow

Typical GPU troubleshooting workflow:

1. Check GPU node resources: `kubectl describe node`
2. Verify GPU operator pods: `kubectl get pods -n gpu-operator`
3. Verify GPU inside pod: `nvidia-smi`
4. Check GPU metrics source: `dcgm-exporter`
