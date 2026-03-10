
# Kubernetes GPU Operator Debugging Guide

The NVIDIA GPU Operator automates the management of GPU drivers, device plugins, monitoring, and other GPU components in Kubernetes.

It installs and manages:

- GPU drivers
- NVIDIA container toolkit
- NVIDIA device plugin
- DCGM exporter
- MIG manager

---  

# Check GPU Nodes

Verify that Kubernetes nodes have GPUs available.

kubectl describe node

Look for:

nvidia.com/gpu

Example:

Capacity:  
nvidia.com/gpu: 4

This means the node has 4 GPUs.
  
---  

# Check GPU Operator Pods

kubectl get pods -n gpu-operator

Expected components:

| Pod | Purpose |  
|----|--------|  
nvidia-driver | installs GPU driver on nodes |  
nvidia-device-plugin | exposes GPUs to Kubernetes |  
dcgm-exporter | exports GPU metrics |  
nvidia-container-toolkit | enables containers to use GPUs |  
mig-manager | manages MIG GPU partitioning |  

Example:

NAME                              STATUS  
nvidia-driver-daemonset           Running  
nvidia-device-plugin-daemonset    Running  
dcgm-exporter                     Running
  
---  

# Verify GPU Access Inside Pod

Example GPU pod configuration:

```yaml  
resources:  
 limits: nvidia.com/gpu: 1  
Deploy pod and check GPU access.  
  
Inside pod:  
  
nvidia-smi  
  
Example output:  
  
+-----------------------------------------------------------------------------+  
| NVIDIA-SMI 580.82       Driver Version: 580.82       CUDA Version: 13.0     |  
+-----------------------------------------------------------------------------+  
  
  
⸻  
  
Check GPU Metrics (DCGM)  
  
DCGM exporter provides GPU metrics for Prometheus.  
  
Port forward metrics endpoint:  
  
kubectl port-forward svc/dcgm-exporter 9400  
  
Open metrics endpoint:  
  
http://localhost:9400/metrics  
  
Example metrics:  
  
DCGM_FI_DEV_GPU_UTIL  
DCGM_FI_DEV_MEM_COPY_UTIL  
DCGM_FI_DEV_POWER_USAGE  
DCGM_FI_DEV_GPU_TEMP  
  
  
⸻  
  
Check MIG Configuration  
  
Check MIG status:  
  
nvidia-smi -mig 1  
  
List MIG profiles:  
  
nvidia-smi -mig -lgip  
  
Create MIG instances:  
  
nvidia-smi -mig -cgi 19,19  
  
  
⸻  
  
Common GPU Operator Issues  
  
GPU Not Detected  
  
Check GPU driver:  
  
ls /proc/driver/nvidia  
  
Check node GPU resources:  
  
kubectl describe node  
  
  
⸻  
  
Device Plugin Not Running  
  
Restart device plugin:  
  
kubectl rollout restart daemonset nvidia-device-plugin  
  
  
⸻  
  
GPU Pods Stuck in Pending  
  
Check pod description:  
  
kubectl describe pod <pod-name>  
  
Possible error:  
  
Insufficient nvidia.com/gpu  
  
Meaning cluster does not have available GPUs.  
  
⸻  
  
Useful Commands  
  
Check GPU resources in cluster:  
  
kubectl get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\.com/gpu  
  
Check GPU pods:  
  
kubectl get pods -A | grep gpu  
  
Check GPU metrics:  
  
kubectl logs dcgm-exporter  
  
  
⸻  
  
Debug Workflow  
  
Typical GPU troubleshooting workflow:  
  
Step 1: Check GPU node resources  
kubectl describe node  
  
Step 2: Verify GPU operator pods  
kubectl get pods -n gpu-operator  
  
Step 3: Verify GPU inside pod  
nvidia-smi  
  
Step 4: Check GPU metrics  
dcgm-exporter