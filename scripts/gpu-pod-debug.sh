#!/bin/bash
# =============================================================================
# Kubernetes GPU Pod Debug Script
# =============================================================================
# Automated debugging of GPU workloads in Kubernetes clusters.
# Checks GPU Operator, node GPU resources, pending/failed GPU pods, DCGM.
#
# Usage: ./gpu-pod-debug.sh
# =============================================================================

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

pass()  { echo -e "${GREEN}✅ PASS${NC}  $1"; }
fail()  { echo -e "${RED}❌ FAIL${NC}  $1"; }
warn()  { echo -e "${YELLOW}⚠️  WARN${NC}  $1"; }
info()  { echo -e "${CYAN}ℹ️  INFO${NC}  $1"; }
header(){ echo -e "\n${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; echo -e "${BOLD}  $1${NC}"; echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# Detect kubectl or oc
if command -v oc &>/dev/null; then
    KUBECTL="oc"
elif command -v kubectl &>/dev/null; then
    KUBECTL="kubectl"
else
    fail "Neither kubectl nor oc found. Please install one."
    exit 1
fi

info "Using: ${KUBECTL}"

# ── GPU Operator Namespace ────────────────────────────────────────────────────
header "1. GPU Operator Status"

GPU_NS=""
for ns in gpu-operator nvidia-gpu-operator nvidia-device-plugin; do
    if $KUBECTL get namespace "$ns" &>/dev/null; then
        GPU_NS="$ns"
        break
    fi
done

if [ -z "$GPU_NS" ]; then
    warn "GPU Operator namespace not found (checked: gpu-operator, nvidia-gpu-operator, nvidia-device-plugin)"
    info "GPU Operator may not be installed"
else
    pass "GPU Operator namespace: ${GPU_NS}"

    info "GPU Operator pods:"
    $KUBECTL get pods -n "$GPU_NS" --no-headers 2>/dev/null | while read -r line; do
        pod_name=$(echo "$line" | awk '{print $1}')
        pod_status=$(echo "$line" | awk '{print $3}')
        if [ "$pod_status" = "Running" ] || [ "$pod_status" = "Completed" ]; then
            pass "  ${pod_name} → ${pod_status}"
        else
            fail "  ${pod_name} → ${pod_status}"
        fi
    done
fi

# ── Node GPU Resources ───────────────────────────────────────────────────────
header "2. Node GPU Resources"

NODES_WITH_GPU=$($KUBECTL get nodes -o custom-columns=NAME:.metadata.name,GPU:.status.allocatable.nvidia\\.com/gpu --no-headers 2>/dev/null || true)

if [ -z "$NODES_WITH_GPU" ]; then
    warn "Could not fetch node GPU resources"
else
    echo "$NODES_WITH_GPU" | while read -r node gpu; do
        if [ "$gpu" != "<none>" ] && [ -n "$gpu" ] && [ "$gpu" != "0" ]; then
            pass "Node ${node}: ${gpu} GPU(s) allocatable"
        else
            info "Node ${node}: No GPUs"
        fi
    done
fi

# Total cluster GPU capacity
TOTAL_GPU=$($KUBECTL get nodes -o jsonpath='{range .items[*]}{.status.allocatable.nvidia\.com/gpu}{"\n"}{end}' 2>/dev/null | awk '{s+=$1} END {print s+0}')
info "Total cluster GPU capacity: ${TOTAL_GPU}"

# ── Pending GPU Pods ──────────────────────────────────────────────────────────
header "3. Pending GPU Pods"

PENDING=$($KUBECTL get pods -A --field-selector=status.phase=Pending --no-headers 2>/dev/null || true)

if [ -z "$PENDING" ]; then
    pass "No pending pods found"
else
    echo "$PENDING" | while read -r line; do
        ns=$(echo "$line" | awk '{print $1}')
        pod=$(echo "$line" | awk '{print $2}')
        # Check if pod requests GPU
        GPU_REQ=$($KUBECTL get pod "$pod" -n "$ns" -o jsonpath='{.spec.containers[*].resources.limits.nvidia\.com/gpu}' 2>/dev/null || true)
        if [ -n "$GPU_REQ" ] && [ "$GPU_REQ" != "0" ]; then
            warn "Pending GPU pod: ${ns}/${pod} (requests ${GPU_REQ} GPU)"
            # Show events
            EVENTS=$($KUBECTL get events -n "$ns" --field-selector "involvedObject.name=${pod}" --sort-by=.lastTimestamp 2>/dev/null | tail -3 || true)
            if [ -n "$EVENTS" ]; then
                echo "    Last events:"
                echo "$EVENTS" | sed 's/^/      /'
            fi
        fi
    done
fi

# ── Failed GPU Pods ───────────────────────────────────────────────────────────
header "4. Failed GPU Pods"

FAILED=$($KUBECTL get pods -A --field-selector=status.phase=Failed --no-headers 2>/dev/null || true)

if [ -z "$FAILED" ]; then
    pass "No failed pods found"
else
    echo "$FAILED" | while read -r line; do
        ns=$(echo "$line" | awk '{print $1}')
        pod=$(echo "$line" | awk '{print $2}')
        GPU_REQ=$($KUBECTL get pod "$pod" -n "$ns" -o jsonpath='{.spec.containers[*].resources.limits.nvidia\.com/gpu}' 2>/dev/null || true)
        if [ -n "$GPU_REQ" ] && [ "$GPU_REQ" != "0" ]; then
            fail "Failed GPU pod: ${ns}/${pod}"
            # Show last 5 log lines
            LOGS=$($KUBECTL logs "$pod" -n "$ns" --tail=5 2>/dev/null || true)
            if [ -n "$LOGS" ]; then
                echo "    Last logs:"
                echo "$LOGS" | sed 's/^/      /'
            fi
        fi
    done
fi

# ── DCGM Exporter Status ─────────────────────────────────────────────────────
header "5. DCGM Exporter"

DCGM_PODS=$($KUBECTL get pods -A -l app=nvidia-dcgm-exporter --no-headers 2>/dev/null || $KUBECTL get pods -A --no-headers 2>/dev/null | grep dcgm || true)

if [ -z "$DCGM_PODS" ]; then
    warn "DCGM exporter pods not found"
else
    echo "$DCGM_PODS" | while read -r line; do
        ns=$(echo "$line" | awk '{print $1}')
        pod=$(echo "$line" | awk '{print $2}')
        status=$(echo "$line" | awk '{print $4}')
        if [ "$status" = "Running" ]; then
            pass "DCGM exporter: ${ns}/${pod} → Running"
        else
            fail "DCGM exporter: ${ns}/${pod} → ${status}"
        fi
    done
fi

# ── GPU Device Plugin ────────────────────────────────────────────────────────
header "6. NVIDIA Device Plugin"

DP_PODS=$($KUBECTL get pods -A --no-headers 2>/dev/null | grep "nvidia-device-plugin" || true)

if [ -z "$DP_PODS" ]; then
    warn "NVIDIA device plugin pods not found"
else
    echo "$DP_PODS" | while read -r line; do
        ns=$(echo "$line" | awk '{print $1}')
        pod=$(echo "$line" | awk '{print $2}')
        status=$(echo "$line" | awk '{print $4}')
        if [ "$status" = "Running" ]; then
            pass "Device plugin: ${ns}/${pod} → Running"
        else
            fail "Device plugin: ${ns}/${pod} → ${status}"
        fi
    done
fi

# ── Summary ───────────────────────────────────────────────────────────────────
header "Summary"
echo ""
info "Cluster GPU capacity: ${TOTAL_GPU} GPU(s)"
pass "GPU pod debug complete"

