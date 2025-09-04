# ==============================
# Stage 1: Build Dependencies
# ==============================
FROM python:3.11.9-slim AS builder

WORKDIR /app

# Install build tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc curl \
    && rm -rf /var/lib/apt/lists/*

# Copy dependency file
COPY requirements.txt .

# Create virtual environment and upgrade pip, setuptools, wheel
# This ensures CVEs in setuptools are patched
RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install --upgrade "setuptools>=70.0.0" wheel \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# ==============================
# Stage 2: Final Runtime Image
# ==============================
FROM python:3.11.9-slim

# Environment settings
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY . .

# Create non-root user
RUN adduser --disabled-password --gecos "" appuser
USER appuser

# Expose Flask default port
EXPOSE 5000

# Optional healthcheck
HEALTHCHECK CMD curl --fail http://localhost:5000/health || exit 1

# Run Gunicorn with multiple workers
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "-w", "4", "app:app"]
