import streamlit as st

st.set_page_config(
    page_title="GPU Scaling Calculator",
    layout="wide"
)

st.title("GPU Scaling Performance Calculator")

st.caption(
    "Estimate distributed training performance using Amdahl's Law and GPU scaling metrics"
)

# -----------------------------
# FORMULA CARD FUNCTION
# -----------------------------

def formula_card(title, formula, example):
    with st.container(border=True):
        st.markdown(f"### {title}")
        st.markdown("**Formula**")
        st.code(formula)
        st.markdown("**Example**")
        st.code(example)


# -----------------------------
# PAGE LAYOUT
# -----------------------------

left, right = st.columns([1.2, 1])

# -----------------------------
# LEFT SIDE (FORMULAS)
# -----------------------------

with left:

    st.subheader("Formulas")

    formula_card(
        "Serial Fraction",
        "Serial Fraction = Serial Time / Total Time\n\nSerial Time = Data Load + Sync",
        "Data Load = 2\nSync = 2\n\nSerial Time = 2 + 2 = 4\nTotal Time = 10\n\nSerial Fraction = 4 / 10 = 0.4"
    )

    formula_card(
        "Amdahl Speedup",
        "Speedup = 1 / Serial Fraction",
        "Serial Fraction = 0.4\n\nSpeedup = 1 / 0.4 = 2.5x"
    )

    formula_card(
        "Actual Speedup",
        "Actual Speedup = Time(1 GPU) / Time(N GPUs)",
        "Training Time (1 GPU) = 1000\nTraining Time (4 GPU) = 400\n\nActual Speedup = 1000 / 400 = 2.5x"
    )

    formula_card(
        "Scaling Efficiency",
        "Efficiency = Actual Speedup / GPU Count",
        "Actual Speedup = 2.5\nGPU Count = 4\n\nEfficiency = 2.5 / 4 = 0.625 = 62.5%"
    )

    formula_card(
        "Global Batch Size",
        "Global Batch = Batch per GPU × GPUs",
        "Batch per GPU = 32\nGPU Count = 4\n\nGlobal Batch = 32 × 4 = 128"
    )


# -----------------------------
# RIGHT SIDE (INPUT + RESULTS)
# -----------------------------

with right:

    st.subheader("Input Parameters")

    col1, col2 = st.columns(2)

    with col1:

        data_load = st.number_input(
            "Data Load Time (sec)",
            value=2.0
        )

        compute = st.number_input(
            "GPU Compute Time (sec)",
            value=6.0
        )

        sync = st.number_input(
            "Synchronization Time (sec)",
            value=2.0
        )

    with col2:

        training_time_1gpu = st.number_input(
            "Training Time (1 GPU)",
            value=1000.0
        )

        training_time_ngpu = st.number_input(
            "Training Time (N GPUs)",
            value=400.0
        )

        gpu_count = st.number_input(
            "GPU Count",
            min_value=1,
            value=4
        )

    batch_per_gpu = st.number_input(
        "Batch Size per GPU",
        min_value=1,
        value=32
    )

    st.subheader("Results")

    # -----------------------------
    # CALCULATIONS
    # -----------------------------

    serial_time = data_load + sync
    total_time = data_load + compute + sync

    serial_fraction = serial_time / total_time
    amdahl_speedup = 1 / serial_fraction

    actual_speedup = training_time_1gpu / training_time_ngpu
    efficiency = actual_speedup / gpu_count

    global_batch = batch_per_gpu * gpu_count

    r1, r2 = st.columns(2)

    with r1:
        st.success(f"Serial Time: {serial_time} sec")
        st.success(f"Serial Fraction: {round(serial_fraction,3)}")
        st.success(f"Amdahl Speedup: {round(amdahl_speedup,2)}x")

    with r2:
        st.success(f"Actual Speedup: {round(actual_speedup,2)}x")
        st.success(f"Scaling Efficiency: {round(efficiency*100,2)}%")
        st.success(f"Global Batch Size: {global_batch}")


# -----------------------------
# HOW TO MEASURE PARAMETERS
# -----------------------------

st.divider()

st.header("How to Measure These Parameters on a GPU Server")

st.markdown("### Data Load Time (PyTorch Example)")

st.code("""
import time
from torch.utils.data import DataLoader

loader = DataLoader(dataset, batch_size=32, num_workers=4)

start = time.time()

for i, batch in enumerate(loader):
    if i == 100:
        break

end = time.time()

data_load_time = (end - start) / 100
print("Data Load Time per batch:", data_load_time)
""", language="python")


st.markdown("### GPU Compute Time")

st.code("""
import torch
import time

start = time.time()

output = model(input)
loss = criterion(output, target)
loss.backward()

torch.cuda.synchronize()

end = time.time()

gpu_compute_time = end - start

print("GPU Compute Time:", gpu_compute_time)
""", language="python")


st.markdown("### NCCL Synchronization Time")

st.code("""
import torch.distributed as dist
import time

dist.barrier()

start = time.time()

dist.all_reduce(tensor)

torch.cuda.synchronize()

end = time.time()

sync_time = end - start

print("NCCL Sync Time:", sync_time)
""", language="python")


st.markdown("### Training Time with 1 GPU")

st.code("""
import time

start = time.time()

train_one_epoch(model, dataloader)

end = time.time()

training_time = end - start

print("Training Time (1 GPU):", training_time)
""", language="python")


st.markdown("### Quick GPU Monitoring Command")

st.code("""
nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv -l 1
""", language="bash")