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

# Install Chrome for selenium
RUN apt-get update && \
    apt-get install -y --no-install-recommends wget && \
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - && \
    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends google-chrome-stable && \
    rm -rf /var/lib/apt/lists/*

# Copy Python dependencies from builder
COPY --from=builder /root/.local /root/.local
COPY --from=builder /app /app

# Ensure scripts in .local are usable
ENV PATH=/root/.local/bin:$PATH
WORKDIR /app

# Default command to run tests
CMD ["pytest"]