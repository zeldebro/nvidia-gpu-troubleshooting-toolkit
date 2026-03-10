# GPU Metrics Troubleshooting Guide

This guide explains how to identify performance bottlenecks in GPU training workloads.

Common GPU training bottlenecks include:

- GPU bottleneck
- Data loading bottleneck
- Disk bottleneck
- Communication bottleneck
- Memory bottleneck

---

# 1 GPU Bottleneck

If GPU utilization is very high, the GPU is fully utilized.

Check GPU utilization:

nvidia-smi –query-gpu=utilization.gpu –format=csv

Example:

utilization.gpu [%]
95 %

Meaning:

GPU is fully utilized and doing heavy computation

No major bottleneck here.

---

# 2 Data Loading Bottleneck

Symptoms:

| Metric | Observation |
|------|-------------|
GPU Utilization | Low |
CPU Utilization | High |
Training Speed | Slow |

Check GPU:

nvidia-smi –query-gpu=utilization.gpu,utilization.memory –format=csv

Check CPU:

top -o %CPU

or

htop

Diagnosis:

CPU cannot load data fast enough for the GPU

Solutions:

- Increase dataloader workers
- Optimize data preprocessing
- Use faster storage

---

# 3 Disk Bottleneck

Check disk performance.

iostat -xz 1

Symptoms:

| Metric | Observation |
|------|-------------|
Disk utilization | High |
Training speed | Slow |
GPU utilization | Low |

Diagnosis:

Dataset loading from disk is too slow

Solutions:

- Use NVMe storage
- Cache datasets
- Use faster filesystem

---

# 4 Communication Bottleneck

Occurs in distributed training.

Symptoms:

- GPU utilization fluctuates
- Training pauses during synchronization

Check GPU topology:

nvidia-smi topo -m

Example:

GPU0 GPU1
PHB

PHB means GPUs communicate through PCIe.

Better option:

NVLink

which provides faster communication.

---

# 5 Memory Bottleneck

Symptoms:

CUDA Out Of Memory

Check GPU memory usage:

nvidia-smi –query-gpu=memory.used,memory.total –format=csv

Example:

15000 MiB / 16000 MiB

Solutions:

- Reduce batch size
- Use mixed precision training
- Gradient checkpointing

---

# Throughput vs Latency

Important performance metrics.

| Metric | Meaning |
|------|--------|
Latency | Time required to complete one task |
Throughput | Number of tasks completed per unit time |

Example:

Latency = 200 ms per request
Throughput = 100 requests per second

---

# Amdahl's Law

Used to estimate scaling efficiency in distributed training.

Formula:

Speedup = 1 / (Serial Fraction + Parallel Fraction / N)

Where:

- Serial Fraction = portion of program that cannot be parallelized
- Parallel Fraction = portion that can run in parallel
- N = number of GPUs

Example:

Serial Fraction = 0.2
Parallel Fraction = 0.8
GPUs = 4

Speedup = 1 / (0.2 + 0.8 / 4)

Meaning:

Training cannot scale infinitely due to serial parts of the workload


