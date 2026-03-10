# NVIDIA GPU Troubleshooting Toolkit

A practical toolkit for debugging GPU workloads, monitoring GPU performance, and troubleshooting NVIDIA GPU infrastructure in Kubernetes environments.

This repository contains command guides, troubleshooting workflows, and scripts used by AI infrastructure engineers to diagnose GPU performance issues.

---

# Repository Structure

gpu-troubleshooting-toolkit
│
├── gpu-scaling-calculator
│   └── gpu_scaling_calculator.py
│
├── kubernetes
│   └── gpu-operator-debug.md
│
├── troubleshooting
│   ├── gpu-metrics.md
│   └── nvidia-smi-guide.md
│
└── requirements.txt

---

# Features

This toolkit helps troubleshoot common GPU issues:

- GPU utilization problems
- GPU memory bottlenecks
- Kubernetes GPU scheduling issues
- Distributed training communication bottlenecks
- Data loading bottlenecks
- GPU performance monitoring

---

# Tools Included

| Tool | Purpose |
|-----|--------|
nvidia-smi guide | GPU monitoring commands |
GPU metrics guide | Detect performance bottlenecks |
GPU operator debugging | Kubernetes GPU troubleshooting |
GPU scaling calculator | Estimate training scaling performance |

---

# GPU Monitoring Commands

Check GPU status

nvidia-smi

Check GPU utilization

nvidia-smi –query-gpu=utilization.gpu –format=csv

Check GPU memory

nvidia-smi –query-gpu=memory.used,memory.total –format=csv

Real-time monitoring

nvidia-smi dmon

---

# Example Troubleshooting Scenario

### Problem

Training job is slow.

GPU utilization = 20%
CPU utilization = 90%

### Diagnosis

Data loading bottleneck.

The GPU is idle waiting for CPU or disk to provide training data.

### Solution

- Increase dataloader workers
- Use NVMe storage
- Optimize preprocessing pipeline

---

# GPU Performance Metrics

Important GPU metrics to monitor:

| Metric | Description |
|------|------------|
GPU Utilization | GPU compute usage |
Memory Utilization | GPU memory usage |
Power Usage | GPU power consumption |
Temperature | GPU thermal status |
PCIe utilization | GPU communication throughput |

---

# Kubernetes GPU Debugging

If using Kubernetes:

Check GPU nodes

kubectl describe node

Check GPU operator pods

kubectl get pods -n gpu-operator

Verify GPU inside pod

nvidia-smi

---

# GPU Scaling Calculator

The `gpu-scaling-calculator` helps estimate training performance scaling.

Example calculation:

Speedup = Training time (1 GPU) / Training time (N GPUs)

Efficiency:

Efficiency = Speedup / Number of GPUs

---

# When to Use This Toolkit

This project is useful for:

- AI Infrastructure Engineers
- DevOps engineers managing GPU clusters
- ML engineers troubleshooting training jobs
- Kubernetes GPU cluster operators

