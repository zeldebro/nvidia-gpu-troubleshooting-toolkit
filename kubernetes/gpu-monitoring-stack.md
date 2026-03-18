# GPU Monitoring Stack — Prometheus + Grafana + DCGM

Set up a complete GPU monitoring pipeline in Kubernetes using DCGM Exporter, Prometheus, and Grafana.

---

## Architecture

```text
┌──────────────┐    ┌────────────┐    ┌──────────┐
│ DCGM Exporter│───▶│ Prometheus │───▶│ Grafana  │
│ (per GPU node)│    │  (scraper) │    │(dashboard)│
└──────────────┘    └────────────┘    └──────────┘
```

- **DCGM Exporter** — Collects GPU metrics and exposes them at `/metrics`
- **Prometheus** — Scrapes and stores GPU metrics
- **Grafana** — Visualizes GPU dashboards

---

## 1. Deploy DCGM Exporter

DCGM Exporter runs as a DaemonSet on all GPU nodes.

### Using Helm

```bash
helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts
helm repo update

helm install dcgm-exporter gpu-helm-charts/dcgm-exporter \
    --namespace gpu-monitoring \
    --create-namespace \
    --set serviceMonitor.enabled=true
```

### Verify

```bash
kubectl get pods -n gpu-monitoring -l app.kubernetes.io/name=dcgm-exporter
kubectl port-forward svc/dcgm-exporter -n gpu-monitoring 9400:9400
curl http://localhost:9400/metrics
```

---

## 2. Key GPU Metrics

| Metric | Description | Unit |
|--------|-------------|------|
| `DCGM_FI_DEV_GPU_UTIL` | GPU compute utilization | % |
| `DCGM_FI_DEV_MEM_COPY_UTIL` | GPU memory utilization | % |
| `DCGM_FI_DEV_GPU_TEMP` | GPU temperature | °C |
| `DCGM_FI_DEV_POWER_USAGE` | GPU power consumption | W |
| `DCGM_FI_DEV_FB_USED` | Framebuffer memory used | MiB |
| `DCGM_FI_DEV_FB_FREE` | Framebuffer memory free | MiB |
| `DCGM_FI_DEV_ENC_UTIL` | Encoder utilization | % |
| `DCGM_FI_DEV_DEC_UTIL` | Decoder utilization | % |
| `DCGM_FI_DEV_SM_CLOCK` | SM clock speed | MHz |
| `DCGM_FI_DEV_MEM_CLOCK` | Memory clock speed | MHz |
| `DCGM_FI_DEV_PCIE_TX_THROUGHPUT` | PCIe TX throughput | KB/s |
| `DCGM_FI_DEV_PCIE_RX_THROUGHPUT` | PCIe RX throughput | KB/s |
| `DCGM_FI_DEV_ECC_SBE_VOL_TOTAL` | Single-bit ECC errors | count |
| `DCGM_FI_DEV_ECC_DBE_VOL_TOTAL` | Double-bit ECC errors | count |
| `DCGM_FI_DEV_XID_ERRORS` | XID errors | count |

---

## 3. Configure Prometheus

### ServiceMonitor (for Prometheus Operator)

```yaml
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: dcgm-exporter
  namespace: gpu-monitoring
  labels:
    release: prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: dcgm-exporter
  endpoints:
  - port: metrics
    interval: 15s
```

### Prometheus Scrape Config (manual)

```yaml
scrape_configs:
  - job_name: 'dcgm-exporter'
    scrape_interval: 15s
    kubernetes_sd_configs:
      - role: pod
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_name]
        regex: dcgm-exporter
        action: keep
```

### Verify in Prometheus

```text
# Open Prometheus UI → Status → Targets
# Look for dcgm-exporter target

# Test query
DCGM_FI_DEV_GPU_UTIL
```

---

## 4. Grafana Dashboard

### Import NVIDIA Dashboard

1. Open Grafana → Dashboards → Import
2. Enter dashboard ID: **12239** (NVIDIA DCGM Exporter Dashboard)
3. Select Prometheus data source
4. Click Import

### Useful Grafana Queries

**GPU Utilization per Node:**

```promql
DCGM_FI_DEV_GPU_UTIL{exported_namespace=~".*"}
```

**GPU Memory Usage (%):**

```promql
DCGM_FI_DEV_FB_USED / (DCGM_FI_DEV_FB_USED + DCGM_FI_DEV_FB_FREE) * 100
```

**GPU Temperature:**

```promql
DCGM_FI_DEV_GPU_TEMP
```

**GPU Power:**

```promql
DCGM_FI_DEV_POWER_USAGE
```

**ECC Errors (alert on any):**

```promql
DCGM_FI_DEV_ECC_DBE_VOL_TOTAL > 0
```

---

## 5. Alerting Rules

### Prometheus Alert Rules for GPU

```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: gpu-alerts
  namespace: gpu-monitoring
spec:
  groups:
  - name: gpu.rules
    rules:
    - alert: GPUHighTemperature
      expr: DCGM_FI_DEV_GPU_TEMP > 85
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "GPU temperature above 85°C"
        description: "GPU {{ $labels.gpu }} on {{ $labels.instance }} is at {{ $value }}°C"

    - alert: GPUMemoryNearFull
      expr: DCGM_FI_DEV_FB_USED / (DCGM_FI_DEV_FB_USED + DCGM_FI_DEV_FB_FREE) * 100 > 95
      for: 5m
      labels:
        severity: warning
      annotations:
        summary: "GPU memory usage above 95%"

    - alert: GPUECCErrors
      expr: DCGM_FI_DEV_ECC_DBE_VOL_TOTAL > 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "Uncorrectable ECC errors detected on GPU"

    - alert: GPUXIDErrors
      expr: DCGM_FI_DEV_XID_ERRORS > 0
      for: 1m
      labels:
        severity: critical
      annotations:
        summary: "XID errors detected — possible hardware issue"
```

---

## 6. Troubleshooting

| Issue | Solution |
|-------|----------|
| No metrics in Prometheus | Check ServiceMonitor labels match Prometheus selector |
| DCGM pods CrashLoopBackOff | Check GPU driver compatibility, run `nvidia-smi` on node |
| Metrics show 0 | Ensure GPU workloads are running |
| Grafana shows "No data" | Verify Prometheus data source URL in Grafana |
