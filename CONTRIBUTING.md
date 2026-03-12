# Contributing to NVIDIA GPU Troubleshooting Toolkit

First off, thank you for considering contributing! 🎉

This project is built by the community, for the community. Every contribution helps GPU engineers debug faster and build better.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Getting Started](#getting-started)
- [Submission Guidelines](#submission-guidelines)
- [Style Guide](#style-guide)
- [Community](#community)

---

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

---

## How Can I Contribute?

### 🐛 Report Bugs

Found a bug or incorrect information? [Open an issue](../../issues/new?template=bug_report.md) with:

- Clear description of the problem
- Steps to reproduce
- Expected vs actual behavior
- GPU model, driver version, CUDA version, OS (if relevant)

### 💡 Suggest Features

Have an idea for a new guide, script, or tool? [Open a feature request](../../issues/new?template=feature_request.md) with:

- Clear description of the feature
- Why it would be useful
- Any relevant examples

### 📝 Add New Troubleshooting Guides

We welcome new guides for:

- Specific GPU models (A100, H100, L40, etc.)
- Specific frameworks (PyTorch, TensorFlow, JAX)
- Specific platforms (AWS, GCP, Azure, on-premise)
- Specific issues you've encountered and solved

### 🛠️ Add New Scripts

Automation scripts that help with:

- GPU diagnostics
- Performance benchmarking
- Cluster health checks
- Log collection

### 📊 Add Grafana Dashboards

Grafana dashboard JSON files for GPU monitoring.

### 📖 Improve Documentation

Fix typos, improve clarity, add examples, update commands for newer driver/CUDA versions.

---

## Getting Started

### Prerequisites

- Git
- Python 3.8+ (for scaling calculator)
- Access to a GPU system (for testing commands)
- kubectl (for Kubernetes guides)

### Setup

```bash
# Fork the repository on GitHub

# Clone your fork
git clone https://github.com/YOUR_USERNAME/nvidia-gpu-troubleshooting-toolkit.git
cd nvidia-gpu-troubleshooting-toolkit

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/nvidia-gpu-troubleshooting-toolkit.git

# Create a branch
git checkout -b feature/my-contribution

# Install dependencies (for scaling calculator)
pip install -r requirements.txt
```

---

## Submission Guidelines

### Pull Requests

1. **Fork** the repo and create your branch from `main`
2. **Make changes** — keep each PR focused on a single topic
3. **Test** your changes where possible
4. **Update documentation** if needed
5. **Submit** a PR with a clear title and description

### PR Title Format

```
Add: new guide for H100 MIG troubleshooting
Fix: incorrect nvidia-smi command in metrics guide
Update: GPU Operator debug steps for v24.x
Script: automated NCCL debug log collector
```

### Commit Messages

Use clear, descriptive commit messages:

```
Add distributed training debug guide with NCCL troubleshooting
Fix nvidia-smi query syntax in GPU metrics guide
Add GPU health check script with temperature warnings
```

---

## Style Guide

### Markdown Guides

- Use `#` headers for main sections
- Use code blocks with language hints (```bash, ```yaml, ```python)
- Include example output for every command
- Add a brief explanation of what each command does
- Use tables for comparing options/metrics
- Add `---` dividers between major sections

### Scripts

- Add a header comment explaining what the script does
- Include usage instructions
- Handle errors gracefully
- Use colors for terminal output (green=pass, red=fail, yellow=warn)
- Make scripts portable (bash, not zsh-specific)

### Python Code

- Follow PEP 8 style
- Add docstrings to functions
- Include type hints where helpful
- Test with Python 3.8+

---

## Community

- Be respectful and constructive
- Help others learn — we were all beginners once
- Share your GPU debugging experiences
- Star ⭐ the repo if you find it useful

---

Thank you for helping make GPU troubleshooting easier for everyone! 🚀

