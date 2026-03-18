# NVIDIA-SMI Guide

`nvidia-smi` is the primary command line tool used to monitor and debug NVIDIA GPUs.

It provides information about:

- GPU utilization
- Memory usage
- Temperature
- Power consumption
- Running processes
- GPU topology

---

## List Available GPUs

nvidia-smi -L

Example output:

GPU 0: Tesla T4 (UUID: GPU-xxxx)

---

## GPU Utilization

Shows how busy the GPU compute units are.

nvidia-smi –query-gpu=utilization.gpu –format=csv

Example:

utilization.gpu [%]
45 %

Meaning:

45% of GPU compute resources are currently used

---

## GPU Memory Usage

Check how much GPU VRAM is being used.

nvidia-smi –query-gpu=memory.used,memory.total –format=csv

Example:

memory.used [MiB], memory.total [MiB]
2000 MiB, 15360 MiB

Meaning:

2GB used out of 15GB GPU memory

---

## GPU Temperature

nvidia-smi –query-gpu=temperature.gpu –format=csv

Example:

temperature.gpu
60 C

Normal GPU temperature range:

40°C – 80°C

---

## GPU Power Usage

nvidia-smi –query-gpu=power.draw,power.limit –format=csv

Example:

power.draw [W], power.limit [W]
60 W, 70 W

Meaning:

GPU is currently using 60 watts out of 70 watts available

---

## GPU Fan Speed

nvidia-smi –query-gpu=fan.speed –format=csv

Example:

fan.speed [%]
40 %

---

## GPU Clock Speeds

nvidia-smi –query-gpu=clocks.current.graphics,clocks.current.sm,clocks.current.memory –format=csv

These represent:

| Metric | Meaning |
| ------ | ------ |
| Graphics Clock | GPU graphics core frequency |
| SM Clock | Streaming multiprocessor frequency |
| Memory Clock | GPU memory frequency |

---

## GPU Running Processes

Shows which processes are using the GPU.

nvidia-smi –query-compute-apps=pid,process_name,used_gpu_memory –format=csv

Example:

pid, process_name, used_gpu_memory
1234 python 5000 MiB

Meaning:

Python process with PID 1234 is using 5GB GPU memory

---

## Real-Time GPU Monitoring

nvidia-smi dmon

Example output:

gpu   sm   mem   enc   dec

0       45   30    0     0

Explanation:

| Column | Meaning |
| ------ | ------ |
| SM | GPU compute utilization |
| MEM | Memory utilization |
| ENC | Video encoder usage |
| DEC | Video decoder usage |

---

## GPU Topology (Multi GPU Systems)

Check GPU interconnects.

nvidia-smi topo -m

Example:

GPU0 GPU1
NV4

Meaning:

GPUs are connected using NVLink

---

## Watch GPU Usage in Real Time

watch -n 1 nvidia-smi

Updates GPU usage every second.

This is useful when debugging training workloads.
