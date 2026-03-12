FROM python:3.11-slim

LABEL maintainer="NVIDIA GPU Troubleshooting Toolkit"
LABEL description="GPU Scaling Calculator — Interactive Streamlit App"

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY gpu-scaling-calculator/ ./gpu-scaling-calculator/

EXPOSE 8501

HEALTHCHECK CMD curl --fail http://localhost:8501/_stcore/health || exit 1

ENTRYPOINT ["streamlit", "run", "gpu-scaling-calculator/gpu_scaling_calculator.py", \
             "--server.port=8501", "--server.address=0.0.0.0", "--server.headless=true"]

