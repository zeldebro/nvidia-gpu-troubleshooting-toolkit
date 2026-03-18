# Distributed Training Troubleshooting Guide

This guide helps debug common issues in multi-GPU and multi-node distributed training using PyTorch DDP, NCCL, and Horovod.

---

## 1. NCCL Communication Errors

NCCL (NVIDIA Collective Communications Library) handles GPU-to-GPU communication.

### Common Errors

```text
NCCL error: unhandled system error
NCCL error: remote process exited
NCCL WARN: Connect to ... failed
```

### Debug Steps (NCCL)

**Enable NCCL debug logs:**

```bash
export NCCL_DEBUG=INFO
export NCCL_DEBUG_SUBSYS=ALL
```

**Check GPU topology:**

```bash
nvidia-smi topo -m
```

**Verify network connectivity between nodes:**

```bash
# Check InfiniBand
ibstat
ibv_devinfo

# Check RoCE
show_gids
```

### Solutions (NCCL)

| Issue | Fix |
| ------- | ------- |
| Firewall blocking NCCL | Open ports 29400-29500 between nodes |
| Wrong network interface | Set `NCCL_SOCKET_IFNAME=eth0` |
| InfiniBand not detected | Set `NCCL_IB_DISABLE=1` to fall back to TCP |
| Timeout errors | Increase `NCCL_SOCKET_TIMEOUT` |

---

## 2. Gradient Synchronization Issues

### Symptoms (Gradient Sync)

- Training loss diverges with multiple GPUs
- Different results with different GPU counts
- Gradient values become NaN

### Debug Steps (Gradient Sync)

**Check gradient values:**

```python
for name, param in model.named_parameters():
    if param.grad is not None:
        print(f"{name}: grad_norm={param.grad.norm():.4f}")
```

**Verify all GPUs have same model state:**

```python
for name, param in model.named_parameters():
    tensor = param.data.clone()
    torch.distributed.all_reduce(tensor)
    tensor /= torch.distributed.get_world_size()
    diff = (param.data - tensor).abs().max()
    print(f"{name}: max_diff={diff:.6f}")
```

### Solutions (Gradient Sync)

- Ensure same random seed across all ranks
- Use `torch.nn.SyncBatchNorm` instead of `BatchNorm`
- Scale learning rate by GPU count: `lr = base_lr * world_size`
- Use gradient clipping to prevent NaN gradients

---

## 3. Hang / Deadlock During Training

### Symptoms (Deadlock)

- Training freezes at a specific step
- All GPUs show 0% utilization after running for a while
- No error messages, just hangs

### Debug Steps (Deadlock)

**Check if all ranks are alive:**

```bash
nvidia-smi --query-compute-apps=pid,process_name --format=csv
```

**Enable NCCL timeout:**

```python
import datetime
import torch.distributed as dist

dist.init_process_group(
    backend="nccl",
    timeout=datetime.timedelta(minutes=30),
)
```

### Common Causes (Deadlock)

| Cause | Fix |
| ------- | ------- |
| Uneven data across ranks | Use `DistributedSampler` with `drop_last=True` |
| Conditional operations | Ensure all ranks execute same code path |
| One rank crashes silently | Add error handling and logging per rank |
| Resource contention | Check CPU/memory usage on all nodes |

---

## 4. Multi-Node Training Setup

### PyTorch DDP Launch

```bash
# Node 0 (master)
torchrun \
  --nproc_per_node=4 \
  --nnodes=2 \
  --node_rank=0 \
  --master_addr=192.168.1.100 \
  --master_port=29500 \
  train.py

# Node 1
torchrun \
  --nproc_per_node=4 \
  --nnodes=2 \
  --node_rank=1 \
  --master_addr=192.168.1.100 \
  --master_port=29500 \
  train.py
```

### Environment Variables

```bash
export NCCL_SOCKET_IFNAME=eth0
export NCCL_IB_HCA=mlx5
export NCCL_NET_GDR_LEVEL=5
export NCCL_P2P_LEVEL=NVL
export CUDA_VISIBLE_DEVICES=0,1,2,3
```

---

## 5. Performance Not Scaling

### Diagnosis

Calculate scaling efficiency:

```text
Efficiency = (Time_1GPU / Time_NGPU) / N
```

| Efficiency | Meaning |
| ------- | ------- |
| > 90% | Excellent |
| 70-90% | Good |
| 50-70% | Communication overhead |
| < 50% | Significant bottleneck |

### Common Causes (Scaling)

| Cause | Solution |
| ------- | ------- |
| Small batch size per GPU | Increase batch size |
| Slow interconnect (PCIe) | Use NVLink or InfiniBand |
| Too many gradient syncs | Use gradient accumulation |
| Data loading bottleneck | Increase `num_workers`, use NVMe |

---

## 6. Useful Debug Commands

```bash
python -c "import torch; print(torch.cuda.nccl.version())"
nvidia-smi topo -m
ibstat
ibv_devinfo
watch -n 1 nvidia-smi
iperf3 -c <remote_ip> -t 10
nccl-tests/build/all_reduce_perf -b 8 -e 128M -f 2 -g 4
```
