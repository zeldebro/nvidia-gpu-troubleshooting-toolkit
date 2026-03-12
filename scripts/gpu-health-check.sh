#!/bin/bash
# =============================================================================
# GPU Health Check Script
# =============================================================================
# Automated GPU health assessment for bare-metal and VM environments.
# Checks driver, CUDA, utilization, memory, temperature, ECC errors, processes.
#
# Usage: ./gpu-health-check.sh
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

pass()  { echo -e "${GREEN}✅ PASS${NC}  $1"; }
fail()  { echo -e "${RED}❌ FAIL${NC}  $1"; }
warn()  { echo -e "${YELLOW}⚠️  WARN${NC}  $1"; }
info()  { echo -e "${CYAN}ℹ️  INFO${NC}  $1"; }
header(){ echo -e "\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BOLD}  $1${NC}"; echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

ERRORS=0
WARNINGS=0

# ── Check nvidia-smi ──────────────────────────────────────────────────────────
header "1. NVIDIA Driver & CUDA"

if ! command -v nvidia-smi &>/dev/null; then
    fail "nvidia-smi not found. NVIDIA driver may not be installed."
    echo -e "${RED}Cannot continue without nvidia-smi. Exiting.${NC}"
    exit 1
fi
pass "nvidia-smi is available"

DRIVER_VERSION=$(nvidia-smi --query-gpu=driver_version --format=csv,noheader | head -1)
CUDA_VERSION=$(nvidia-smi --query-gpu=compute_cap --format=csv,noheader 2>/dev/null | head -1 || echo "N/A")
info "Driver Version: ${DRIVER_VERSION}"

# ── GPU Count & Models ────────────────────────────────────────────────────────
header "2. GPU Inventory"

GPU_COUNT=$(nvidia-smi --query-gpu=name --format=csv,noheader | wc -l | tr -d ' ')
info "GPU Count: ${GPU_COUNT}"

nvidia-smi --query-gpu=index,name,uuid --format=csv,noheader | while IFS=',' read -r idx name uuid; do
    info "  GPU ${idx}: ${name} (${uuid})"
done

# ── GPU Utilization ───────────────────────────────────────────────────────────
header "3. GPU Utilization"

nvidia-smi --query-gpu=index,utilization.gpu,utilization.memory --format=csv,noheader | while IFS=',' read -r idx gpu_util mem_util; do
    gpu_pct=$(echo "$gpu_util" | tr -dc '0-9')
    mem_pct=$(echo "$mem_util" | tr -dc '0-9')

    if [ "$gpu_pct" -gt 95 ]; then
        warn "GPU ${idx}: Compute ${gpu_util} (very high)"
        WARNINGS=$((WARNINGS+1))
    else
        pass "GPU ${idx}: Compute ${gpu_util} | Memory ${mem_util}"
    fi
done

# ── GPU Memory ────────────────────────────────────────────────────────────────
header "4. GPU Memory"

nvidia-smi --query-gpu=index,memory.used,memory.total,memory.free --format=csv,noheader | while IFS=',' read -r idx used total free; do
    used_mb=$(echo "$used" | tr -dc '0-9')
    total_mb=$(echo "$total" | tr -dc '0-9')

    if [ "$total_mb" -gt 0 ]; then
        pct=$((used_mb * 100 / total_mb))
        if [ "$pct" -gt 95 ]; then
            warn "GPU ${idx}: ${used} / ${total} (${pct}% — near capacity)"
        else
            pass "GPU ${idx}: ${used} / ${total} (${pct}%)"
        fi
    else
        info "GPU ${idx}: ${used} / ${total}"
    fi
done

# ── GPU Temperature ───────────────────────────────────────────────────────────
header "5. GPU Temperature"

nvidia-smi --query-gpu=index,temperature.gpu --format=csv,noheader | while IFS=',' read -r idx temp; do
    temp_val=$(echo "$temp" | tr -dc '0-9')

    if [ "$temp_val" -gt 85 ]; then
        fail "GPU ${idx}: ${temp_val}°C — OVERHEATING"
        ERRORS=$((ERRORS+1))
    elif [ "$temp_val" -gt 75 ]; then
        warn "GPU ${idx}: ${temp_val}°C — Warm"
    else
        pass "GPU ${idx}: ${temp_val}°C"
    fi
done

# ── GPU Power ─────────────────────────────────────────────────────────────────
header "6. GPU Power"

nvidia-smi --query-gpu=index,power.draw,power.limit --format=csv,noheader | while IFS=',' read -r idx draw limit; do
    pass "GPU ${idx}: Drawing ${draw} / Limit ${limit}"
done

# ── ECC Errors ────────────────────────────────────────────────────────────────
header "7. ECC Errors"

nvidia-smi --query-gpu=index,ecc.errors.corrected.volatile.total,ecc.errors.uncorrected.volatile.total --format=csv,noheader 2>/dev/null | while IFS=',' read -r idx corrected uncorrected; do
    corr_val=$(echo "$corrected" | tr -dc '0-9')
    uncorr_val=$(echo "$uncorrected" | tr -dc '0-9')

    if [ -n "$uncorr_val" ] && [ "$uncorr_val" -gt 0 ] 2>/dev/null; then
        fail "GPU ${idx}: ${uncorr_val} uncorrectable ECC errors — investigate immediately"
        ERRORS=$((ERRORS+1))
    elif [ -n "$corr_val" ] && [ "$corr_val" -gt 0 ] 2>/dev/null; then
        warn "GPU ${idx}: ${corr_val} correctable ECC errors"
    else
        pass "GPU ${idx}: No ECC errors"
    fi
done || info "ECC not supported on this GPU model"

# ── GPU Processes ─────────────────────────────────────────────────────────────
header "8. GPU Processes"

PROCS=$(nvidia-smi --query-compute-apps=pid,process_name,used_gpu_memory --format=csv,noheader 2>/dev/null || true)

if [ -z "$PROCS" ]; then
    info "No GPU processes running"
else
    echo "$PROCS" | while IFS=',' read -r pid name mem; do
        info "  PID ${pid}: ${name} using ${mem}"
    done
fi

# ── GPU Topology ──────────────────────────────────────────────────────────────
if [ "$GPU_COUNT" -gt 1 ]; then
    header "9. GPU Topology (Multi-GPU)"
    nvidia-smi topo -m 2>/dev/null || info "Topology info not available"
fi

# ── Summary ───────────────────────────────────────────────────────────────────
header "Summary"

echo ""
info "GPUs: ${GPU_COUNT} | Driver: ${DRIVER_VERSION}"
if [ "$ERRORS" -gt 0 ]; then
    fail "Health check completed with ${ERRORS} error(s) and ${WARNINGS} warning(s)"
    exit 1
elif [ "$WARNINGS" -gt 0 ]; then
    warn "Health check completed with ${WARNINGS} warning(s)"
    exit 0
else
    pass "All GPU health checks passed"
    exit 0
fi

