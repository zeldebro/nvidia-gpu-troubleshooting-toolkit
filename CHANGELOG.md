# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.0.0] - 2026-03-12

### Added

- **README.md** — Enhanced with badges, table of contents, feature matrix, quick start, scenarios, metrics reference, community section
- **GPU Scaling Calculator** — Interactive Streamlit app for distributed training performance estimation using Amdahl's Law
- **Troubleshooting Guides**
  - `nvidia-smi-guide.md` — Complete nvidia-smi command reference with examples
  - `gpu-metrics.md` — GPU bottleneck identification (compute, data, disk, communication, memory)
  - `distributed-training-debug.md` — NCCL, gradient sync, multi-node training debugging
  - `gpu-memory-optimization.md` — OOM fixes, mixed precision, gradient checkpointing, memory estimation
- **Kubernetes GPU Guides**
  - `gpu-operator-debug.md` — NVIDIA GPU Operator troubleshooting in Kubernetes
  - `gpu-monitoring-stack.md` — Prometheus + Grafana + DCGM GPU monitoring setup
  - `gpu-pod-examples.md` — Ready-to-use GPU pod, job, deployment, MIG, CronJob YAML templates
- **Automated Scripts**
  - `scripts/gpu-health-check.sh` — One-command GPU health assessment (driver, memory, temp, ECC, processes)
  - `scripts/gpu-pod-debug.sh` — Kubernetes GPU pod debugging (operator, nodes, pending/failed pods, DCGM)
- **Docker Support** — Dockerfile for containerized scaling calculator
- **Makefile** — Easy project commands (`make run`, `make docker-build`, `make health-check`, etc.)
- **CI/CD** — GitHub Actions workflow for markdown lint, shell lint, Docker build, Streamlit syntax check
- **Community Files**
  - `CONTRIBUTING.md` — Contribution guidelines
  - `CODE_OF_CONDUCT.md` — Contributor Covenant Code of Conduct
  - `LICENSE` — Apache License 2.0
  - `.github/ISSUE_TEMPLATE/bug_report.md` — Bug report template
  - `.github/ISSUE_TEMPLATE/feature_request.md` — Feature request template
  - `.github/PULL_REQUEST_TEMPLATE.md` — PR template
