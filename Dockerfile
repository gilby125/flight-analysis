# Use official Python base image
FROM python:3.9-slim as builder

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install system dependencies with retries
RUN apt-get update || apt-get update && \
    apt-get install -y --no-install-recommends gcc python3-dev && \
    rm -rf /var/lib/apt/lists/*

# Add wait-for-it script for dependencies
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /wait-for-it.sh
RUN chmod +x /wait-for-it.sh

# Set working directory
WORKDIR /app

# Copy requirements first to leverage Docker cache
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Copy project files
COPY . .

# Runtime stage
FROM python:3.9-slim

# Install Chromium for selenium (more reliable than Chrome in containers)
RUN apt-get update || apt-get update && \
    apt-get install -y --no-install-recommends chromium && \
    rm -rf /var/lib/apt/lists/*

# Set Chromium as default browser
ENV CHROMIUM_FLAGS="--no-sandbox --disable-dev-shm-usage"

# Copy Python dependencies from builder
COPY --from=builder /root/.local /root/.local
COPY --from=builder /app /app

# Ensure scripts in .local are usable
ENV PATH=/root/.local/bin:$PATH
WORKDIR /app

# Default command to run tests
CMD ["pytest"]