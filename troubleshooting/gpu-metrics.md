# GPU Metrics Troubleshooting Guide

This guide explains how to identify performance bottlenecks in GPU training workloads.

Common bottlenecks include:

- GPU bottleneck
- Data loading bottleneck
- Disk bottleneck
- Communication bottleneck
- Memory bottleneck

---

## 1. GPU Bottleneck

If GPU utilization is very high, the GPU is fully utilized.

Check GPU utilization:

```bash
nvidia-smi --query-gpu=utilization.gpu --format=csv
```

Example:

```text
utilization.gpu [%]
95 %
```

Meaning: GPU is fully utilized and doing heavy computation.

No major bottleneck here.

---

## 2. Data Loading Bottleneck

Symptoms:

| Metric | Observation |
| ------ | ----------- |
| GPU Utilization | Low |
| CPU Utilization | High |
| Training Speed | Slow |

Check GPU:

```bash
nvidia-smi --query-gpu=utilization.gpu,utilization.memory --format=csv
```

Check CPU:

```bash
top -o %CPU
# or
htop
```

Diagnosis: CPU cannot load data fast enough for the GPU.

Solutions:

- Increase dataloader workers
- Optimize data preprocessing
- Use faster storage

---

## 3. Disk Bottleneck

Check disk performance:

```bash
iostat -xz 1
```

Symptoms:

| Metric | Observation |
| ------ | ----------- |
| Disk utilization | High |
| Training speed | Slow |
| GPU utilization | Low |

Diagnosis: dataset loading from disk is too slow.

Solutions:

- Use NVMe storage
- Cache datasets
- Use faster filesystem

---

## 4. Communication Bottleneck

Occurs in distributed training.

Symptoms:

- GPU utilization fluctuates
- Training pauses during synchronization

Check GPU topology:

```bash
nvidia-smi topo -m
```

Example:

```text
GPU0 GPU1
PHB
```

`PHB` means GPUs communicate through PCIe.

Better option: `NVLink`, which provides faster communication.

---

## 5. Memory Bottleneck

Symptoms:

```text
CUDA Out Of Memory
```

Check GPU memory usage:

```bash
nvidia-smi --query-gpu=memory.used,memory.total --format=csv
```

Example:

```text
15000 MiB / 16000 MiB
```

Solutions:

- Reduce batch size
- Use mixed precision training
- Use gradient checkpointing

---

## Throughput vs Latency

Important performance metrics:

| Metric | Meaning |
| ------ | ------- |
| Latency | Time required to complete one task |
| Throughput | Number of tasks completed per unit time |

Example:

```text
Latency = 200 ms per request
Throughput = 100 requests per second
```

---

## Amdahl's Law

Used to estimate scaling efficiency in distributed training.

Formula:

```text
Speedup = 1 / (Serial Fraction + Parallel Fraction / N)
```

Where:

- Serial Fraction = portion of program that cannot be parallelized
- Parallel Fraction = portion that can run in parallel
- N = number of GPUs

Example:

```text
Serial Fraction = 0.2
Parallel Fraction = 0.8
GPUs = 4
Speedup = 1 / (0.2 + 0.8 / 4)
```

Meaning: training cannot scale infinitely due to serial parts of the workload.
