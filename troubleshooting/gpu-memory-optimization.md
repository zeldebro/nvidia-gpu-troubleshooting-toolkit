# GPU Memory Optimization Guide

Techniques to fix out-of-memory (OOM) errors and optimize GPU VRAM usage during training and inference.

---

## 1. Identify the Problem

### Check Current GPU Memory Usage

```bash
nvidia-smi --query-gpu=memory.used,memory.total,memory.free --format=csv
```

### Monitor Memory During Training

```python
import torch


def print_gpu_memory():
    allocated = torch.cuda.memory_allocated() / 1e9
    reserved = torch.cuda.memory_reserved() / 1e9
    print(f"Allocated: {allocated:.2f} GB | Reserved: {reserved:.2f} GB")
```

### Common OOM Error

```text
RuntimeError: CUDA out of memory.
Tried to allocate 256.00 MiB (GPU 0; 15.78 GiB total capacity;
13.02 GiB already allocated; 221.12 MiB free)
```

---

## 2. Reduce Batch Size

The simplest fix. Memory usage scales linearly with batch size.

```python
# Before - OOM
train_loader = DataLoader(dataset, batch_size=64)

# After - fits in memory
train_loader = DataLoader(dataset, batch_size=16)
```

**Trade-off:** Smaller batch size means more training steps and longer training time.

---

## 3. Mixed Precision Training (FP16/BF16)

Reduces memory usage by ~50% with minimal accuracy impact.

### PyTorch Native AMP

```python
from torch.cuda.amp import autocast, GradScaler

scaler = GradScaler()

for data, target in loader:
    optimizer.zero_grad()

    with autocast():
        output = model(data)
        loss = criterion(output, target)

    scaler.scale(loss).backward()
    scaler.step(optimizer)
    scaler.update()
```

### Memory Savings (Precision)

| Precision | Memory per Parameter |
| ----------- | ---------------------- |
| FP32 | 4 bytes |
| FP16 / BF16 | 2 bytes |
| INT8 | 1 byte |

---

## 4. Gradient Checkpointing

Trades compute for memory by recomputing intermediate activations during backward pass instead of storing them.

### PyTorch Example

```python
from torch.utils.checkpoint import checkpoint

class MyModel(nn.Module):
    def forward(self, x):
        x = checkpoint(self.block1, x)
        x = checkpoint(self.block2, x)
        x = self.head(x)
        return x
```

### Memory Savings (Checkpointing)

| Model Size | Without Checkpointing | With Checkpointing |
| ----------- | ---------------------- | ------------------- |
| 1B params | 16 GB | 8 GB |
| 7B params | 56 GB | 20 GB |

**Trade-off:** ~20-30% slower training due to recomputation.

---

## 5. Gradient Accumulation

Simulate larger batch sizes without increasing memory.

```python
accumulation_steps = 4

for i, (data, target) in enumerate(loader):
    output = model(data)
    loss = criterion(output, target) / accumulation_steps
    loss.backward()

    if (i + 1) % accumulation_steps == 0:
        optimizer.step()
        optimizer.zero_grad()
```

**Effect:** Effective batch size = `batch_size * accumulation_steps`

---

## 6. Model Parallelism

Split model across multiple GPUs when it does not fit on a single GPU.

### Pipeline Parallelism

```python
model.layer1.to("cuda:0")
model.layer2.to("cuda:1")


def forward(x):
    x = model.layer1(x.to("cuda:0"))
    x = model.layer2(x.to("cuda:1"))
    return x
```

### Tensor Parallelism

Split individual layers across GPUs. Libraries: Megatron-LM, DeepSpeed.

---

## 7. Memory-Efficient Optimizers

Some optimizers use less GPU memory.

| Optimizer | Memory per Parameter |
| ----------- | --------------------- |
| Adam | 8 bytes (2 states) |
| AdamW | 8 bytes (2 states) |
| SGD | 4 bytes (momentum) |
| Adafactor | 4 bytes |
| 8-bit Adam (bitsandbytes) | 2 bytes |

### 8-bit Adam

```python
import bitsandbytes as bnb

optimizer = bnb.optim.Adam8bit(model.parameters(), lr=1e-4)
```

---

## 8. Clear GPU Cache

```python
import gc
import torch

# Clear cache
torch.cuda.empty_cache()

# Force garbage collection
gc.collect()
```

**Note:** `empty_cache()` releases unused cached memory but does not free allocated tensors.

---

## 9. Inference Optimization

### Use `torch.no_grad()` During Inference

```python
with torch.no_grad():
    output = model(input_data)
```

### Delete Intermediate Tensors

```python
output = model(data)
loss = criterion(output, target)

del output  # Free memory immediately
torch.cuda.empty_cache()
```

---

## 10. Memory Estimation Formula

```text
Total GPU Memory = Model Parameters + Gradients + Optimizer States + Activations + Framework Overhead

Model (FP32):     params x 4 bytes
Gradients:        params x 4 bytes
Adam States:      params x 8 bytes
Activations:      depends on batch size and model architecture
```

### Example: 1B Parameter Model (FP32 + Adam)

```text
Model:      1B x 4 bytes = 4 GB
Gradients:  1B x 4 bytes = 4 GB
Adam:       1B x 8 bytes = 8 GB
Total:      ~16 GB + activations
```

---

## Quick Fix Checklist

| Technique | Memory Savings | Speed Impact |
| -------- | --------------- | ------------- |
| Reduce batch size | Proportional | More steps |
| Mixed precision (FP16) | ~50% | Slightly faster |
| Gradient checkpointing | ~40-60% | ~20-30% slower |
| Gradient accumulation | Same as small batch | Same |
| 8-bit optimizer | ~50% optimizer states | Minimal |
| `torch.no_grad()` for eval | Saves activation memory | None |
| Clear cache | Frees unused memory | None |
