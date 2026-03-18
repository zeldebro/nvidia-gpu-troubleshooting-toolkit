<p align="center">
  <img src="https://img.shields.io/badge/NVIDIA-GPU%20Toolkit-76B900?style=for-the-badge&logo=nvidia&logoColor=white" alt="NVIDIA GPU Toolkit"/>
</p>

<h1 align="center">🔧 NVIDIA GPU Troubleshooting Toolkit</h1>

<p align="center">
  <strong>A practical, open-source toolkit for debugging GPU workloads, monitoring GPU performance, and troubleshooting NVIDIA GPU infrastructure in Kubernetes and bare-metal environments.</strong>
</p>

<p align="center">
  <a href="#-features"><img src="https://img.shields.io/badge/Features-✨-blue?style=flat-square" alt="Features"/></a>
  <a href="#-quick-start"><img src="https://img.shields.io/badge/Quick%20Start-🚀-green?style=flat-square" alt="Quick Start"/></a>
  <a href="CONTRIBUTING.md"><img src="https://img.shields.io/badge/PRs-Welcome-brightgreen?style=flat-square" alt="PRs Welcome"/></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-blue?style=flat-square" alt="License"/></a>
  <img src="https://img.shields.io/github/stars/zeldebro/nvidia-gpu-troubleshooting-toolkit?style=flat-square" alt="Stars"/>
  <img src="https://img.shields.io/github/forks/zeldebro/nvidia-gpu-troubleshooting-toolkit?style=flat-square" alt="Forks"/>
  <img src="https://img.shields.io/github/issues/zeldebro/nvidia-gpu-troubleshooting-toolkit?style=flat-square" alt="Issues"/>
</p>

---

## 📖 Table of Contents

- [Features](#-features)
- [Repository Structure](#-repository-structure)
- [Quick Start](#-quick-start)
- [Troubleshooting Guides](#-troubleshooting-guides)
- [Kubernetes GPU Guides](#-kubernetes-gpu-guides)
- [GPU Scaling Calculator](#-gpu-scaling-calculator)
- [Automated Scripts](#-automated-scripts)
- [GPU Monitoring Commands](#-gpu-monitoring-commands)
- [Example Troubleshooting Scenarios](#-example-troubleshooting-scenarios)
- [GPU Performance Metrics Reference](#-gpu-performance-metrics-reference)
- [Contributing](#-contributing)
- [Community](#-community)
- [License](#-license)

---

## ✨ Features

| Category | What You Get |
|----------|-------------|
| 🔍 **Troubleshooting Guides** | Step-by-step guides for GPU utilization, memory, communication, and disk bottlenecks |
| ☸️ **Kubernetes GPU Debugging** | GPU Operator debugging, pod scheduling, DCGM metrics, monitoring stack setup |
| 📊 **GPU Scaling Calculator** | Interactive Streamlit app to estimate distributed training performance using Amdahl's Law |
| 🛠️ **Automated Scripts** | One-command GPU health checks and Kubernetes GPU pod debugging |
| 📈 **Monitoring Stack** | Prometheus + Grafana GPU monitoring setup with DCGM exporter |
| 🐳 **Docker Support** | Run the scaling calculator in a container |
| 📝 **GPU Pod Examples** | Ready-to-use Kubernetes GPU pod, job, and deployment YAML templates |

---

## 📁 Repository Structure

```
nvidia-gpu-troubleshooting-toolkit/
│
├── gpu-scaling-calculator/
│   └── gpu_scaling_calculator.py        # Interactive Streamlit GPU scaling calculator
│
├── kubernetes/
│   ├── gpu-operator-debug.md            # GPU Operator troubleshooting guide
│   ├── gpu-monitoring-stack.md          # Prometheus + Grafana GPU monitoring
│   └── gpu-pod-examples.md             # Example GPU pod/job/deployment YAMLs
│
├── troubleshooting/
│   ├── nvidia-smi-guide.md             # Complete nvidia-smi command reference
│   ├── gpu-metrics.md                  # GPU metrics & bottleneck identification
│   ├── distributed-training-debug.md   # Distributed training troubleshooting
│   └── gpu-memory-optimization.md      # GPU memory optimization techniques
│
├── scripts/
│   ├── gpu-health-check.sh             # Automated GPU health check
│   └── gpu-pod-debug.sh                # Kubernetes GPU pod debugger
│
├── Dockerfile                           # Container for scaling calculator
├── Makefile                             # Easy project commands
├── requirements.txt                     # Python dependencies
├── CONTRIBUTING.md                      # Contribution guidelines
├── CODE_OF_CONDUCT.md                   # Community standards
└── LICENSE                              # Apache 2.0 License
```

---

## 🚀 Quick Start

### Option 1: Clone and Explore Guides

```bash
git clone https://github.com/zeldebro/nvidia-gpu-troubleshooting-toolkit.git
cd nvidia-gpu-troubleshooting-toolkit
```

### Option 2: Run GPU Scaling Calculator

```bash
pip install -r requirements.txt
streamlit run gpu-scaling-calculator/gpu_scaling_calculator.py
```

### Option 3: Run with Docker

```bash
docker build -t gpu-toolkit .
docker run -p 8501:8501 gpu-toolkit
```

### Option 4: Run Automated GPU Health Check

```bash
chmod +x scripts/gpu-health-check.sh
./scripts/gpu-health-check.sh
```

### Option 5: Debug GPU Pods in Kubernetes

```bash
chmod +x scripts/gpu-pod-debug.sh
./scripts/gpu-pod-debug.sh
```

---

## 🔍 Troubleshooting Guides

| Guide | Description |
|-------|-------------|
| [nvidia-smi Guide](troubleshooting/nvidia-smi-guide.md) | Complete reference for `nvidia-smi` commands — utilization, memory, temperature, processes, topology |
| [GPU Metrics & Bottlenecks](troubleshooting/gpu-metrics.md) | Identify GPU, data loading, disk, communication, and memory bottlenecks |
| [Distributed Training Debug](troubleshooting/distributed-training-debug.md) | Troubleshoot NCCL, gradient sync, multi-node training issues |
| [GPU Memory Optimization](troubleshooting/gpu-memory-optimization.md) | Fix OOM errors, optimize VRAM usage, mixed precision, gradient checkpointing |

---

## ☸️ Kubernetes GPU Guides

| Guide | Description |
|-------|-------------|
| [GPU Operator Debug](kubernetes/gpu-operator-debug.md) | Debug NVIDIA GPU Operator, device plugin, driver issues in Kubernetes |
| [GPU Monitoring Stack](kubernetes/gpu-monitoring-stack.md) | Set up Prometheus + Grafana + DCGM for GPU monitoring |
| [GPU Pod Examples](kubernetes/gpu-pod-examples.md) | Ready-to-use GPU pod, job, deployment, and MIG YAML examples |

---

## 📊 GPU Scaling Calculator

An interactive **Streamlit** web application that calculates:

- **Serial Fraction** — portion of workload that can't be parallelized
- **Amdahl's Speedup** — theoretical maximum speedup
- **Actual Speedup** — measured speedup with N GPUs
- **Scaling Efficiency** — how well GPUs scale
- **Global Batch Size** — effective batch size across GPUs

```bash
streamlit run gpu-scaling-calculator/gpu_scaling_calculator.py
```

<details>
<summary>📸 Screenshot Preview</summary>

The calculator provides a split-screen layout:
- **Left**: Formula cards with explanations and examples
- **Right**: Interactive input parameters with real-time results

</details>

---

## 🛠️ Automated Scripts

### GPU Health Check (`scripts/gpu-health-check.sh`)

One-command GPU health assessment:

```bash
./scripts/gpu-health-check.sh
```

**What it checks:**
- ✅ nvidia-smi availability
- ✅ GPU driver version
- ✅ CUDA version
- ✅ GPU count and model
- ✅ GPU utilization per GPU
- ✅ Memory usage per GPU
- ✅ Temperature warnings (>85°C)
- ✅ ECC error detection
- ✅ GPU process listing

### Kubernetes GPU Pod Debug (`scripts/gpu-pod-debug.sh`)

```bash
./scripts/gpu-pod-debug.sh
```

**What it checks:**
- ✅ GPU Operator namespace and pods
- ✅ Node GPU allocatable resources
- ✅ Pending GPU pods
- ✅ Failed GPU pods
- ✅ DCGM exporter status

---

## 📈 GPU Monitoring Commands

### Quick Reference

| Command | Purpose |
|---------|---------|
| `nvidia-smi` | Full GPU status overview |
| `nvidia-smi -L` | List all GPUs |
| `nvidia-smi dmon` | Real-time GPU monitoring |
| `nvidia-smi topo -m` | GPU topology / interconnects |
| `nvidia-smi --query-gpu=utilization.gpu --format=csv` | GPU utilization |
| `nvidia-smi --query-gpu=memory.used,memory.total --format=csv` | GPU memory |
| `nvidia-smi --query-gpu=temperature.gpu --format=csv` | GPU temperature |
| `nvidia-smi --query-gpu=power.draw,power.limit --format=csv` | GPU power |
| `nvidia-smi --query-compute-apps=pid,process_name,used_gpu_memory --format=csv` | GPU processes |
| `watch -n 1 nvidia-smi` | Live GPU monitoring |

---

## 🧪 Example Troubleshooting Scenarios

<details>
<summary><strong>Scenario 1: Training job is slow — Low GPU utilization</strong></summary>

**Symptoms:**
- GPU utilization: 20%
- CPU utilization: 90%

**Diagnosis:** Data loading bottleneck — GPU is idle waiting for CPU/disk.

**Solution:**
1. Increase dataloader workers (`num_workers=8`)
2. Use NVMe storage for datasets
3. Optimize data preprocessing pipeline
4. Use `prefetch_factor` in DataLoader

</details>

<details>
<summary><strong>Scenario 2: CUDA Out of Memory</strong></summary>

**Symptoms:**
- `RuntimeError: CUDA out of memory`
- Training crashes immediately

**Diagnosis:** Model or batch size exceeds GPU VRAM.

**Solution:**
1. Reduce batch size
2. Enable mixed precision training (`torch.cuda.amp`)
3. Use gradient checkpointing
4. Use gradient accumulation

</details>

<details>
<summary><strong>Scenario 3: GPU pods stuck in Pending</strong></summary>

**Symptoms:**
- Pod status: `Pending`
- Event: `Insufficient nvidia.com/gpu`

**Diagnosis:** No available GPU resources in cluster.

**Solution:**
1. Check node GPU capacity: `kubectl describe node`
2. Verify GPU Operator is running: `kubectl get pods -n gpu-operator`
3. Check if other pods are consuming GPUs
4. Scale GPU node pool

</details>

<details>
<summary><strong>Scenario 4: Multi-GPU training not scaling</strong></summary>

**Symptoms:**
- 4 GPUs but only 1.5x speedup
- High serial fraction

**Diagnosis:** Communication overhead or serial bottleneck.

**Solution:**
1. Check GPU topology: `nvidia-smi topo -m`
2. Prefer NVLink over PCIe
3. Increase batch size per GPU
4. Use NCCL tuning variables

</details>

---

## 📋 GPU Performance Metrics Reference

| Metric | Description | Healthy Range |
|--------|-------------|---------------|
| GPU Utilization | GPU compute core usage | 80-100% during training |
| Memory Utilization | GPU VRAM usage | < 95% |
| Power Usage | GPU power consumption | Below power limit |
| Temperature | GPU thermal status | 40°C – 85°C |
| PCIe Throughput | GPU-CPU communication | Depends on workload |
| NVLink Throughput | GPU-GPU communication | Higher is better |
| ECC Errors | Memory error count | 0 (any errors = investigate) |
| SM Clock | Streaming multiprocessor freq | At boost clock |

---

## 🤝 Contributing

We welcome contributions from the community! Whether it's:

- 🐛 Bug fixes
- 📝 New troubleshooting guides
- 🛠️ New scripts or tools
- 📊 Dashboard templates
- 📖 Documentation improvements

Please read our [Contributing Guide](CONTRIBUTING.md) and [Code of Conduct](CODE_OF_CONDUCT.md) before submitting.

### Quick Contribution Steps

```bash
# Fork the repo
git clone https://github.com/zeldebro/nvidia-gpu-troubleshooting-toolkit.git
cd nvidia-gpu-troubleshooting-toolkit

# Create a branch
git checkout -b feature/my-new-guide

# Make changes and commit
git add .
git commit -m "Add: new troubleshooting guide for XYZ"

# Push and create PR
git push origin feature/my-new-guide
```

---

## 🌐 Community

- ⭐ **Star this repo** if you find it useful
- 🐛 [Report bugs](../../issues/new?template=bug_report.md)
- 💡 [Request features](../../issues/new?template=feature_request.md)
- 💬 [Start a discussion](../../discussions)
- 🔀 [Submit a PR](../../pulls)

### Who Is This For?

| Role | Use Case |
|------|----------|
| 🧑‍💻 **AI/ML Engineers** | Debug training jobs, optimize GPU utilization |
| ⚙️ **DevOps / SRE** | Monitor GPU clusters, troubleshoot scheduling |
| ☸️ **Kubernetes Admins** | GPU Operator debugging, pod scheduling issues |
| 🔬 **Researchers** | Optimize distributed training, scaling analysis |
| 🏗️ **Platform Engineers** | Build GPU monitoring stacks, automate health checks |

---

## 📄 License

This project is licensed under the [Apache License 2.0](LICENSE).

---

<p align="center">
  <strong>Made with ❤️ for the GPU community</strong>
  <br/>
  <sub>If this toolkit helped you, give it a ⭐ — it helps others find it too!</sub>
</p>

