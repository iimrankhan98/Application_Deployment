# Stage 1: Build Dependenciess
FROM python:3.11-slim AS builder
WORKDIR /app
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN python -m venv /opt/venv \
    && /opt/venv/bin/pip install --upgrade pip \
    && /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# Stage 2: Final Runtime Image
FROM python:3.11-slim

ENV PYTHONUNBUFFERED=1 \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /app

COPY --from=builder /opt/venv /opt/venv

# Copy application code
COPY . .

# Expose Flask default port
EXPOSE 5000

# Command to run the app (can be changed if using gunicorn)
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "app:app"]
