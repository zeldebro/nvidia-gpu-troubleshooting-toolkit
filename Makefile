.PHONY: help run docker-build docker-run health-check gpu-debug clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

run: ## Run the GPU Scaling Calculator locally
	pip install -r requirements.txt
	streamlit run gpu-scaling-calculator/gpu_scaling_calculator.py

docker-build: ## Build Docker image
	docker build -t gpu-toolkit .

docker-run: ## Run Docker container
	docker run -p 8501:8501 gpu-toolkit

health-check: ## Run GPU health check script
	chmod +x scripts/gpu-health-check.sh
	./scripts/gpu-health-check.sh

gpu-debug: ## Run Kubernetes GPU pod debug script
	chmod +x scripts/gpu-pod-debug.sh
	./scripts/gpu-pod-debug.sh

clean: ## Remove Python cache files
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true

