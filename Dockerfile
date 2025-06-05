# Use Alpine-based Python image
FROM python:3.9-alpine

# Install system dependencies
RUN apk add --no-cache \
    chromium \
    chromium-chromedriver \
    build-base \
    libffi-dev \
    openssl-dev

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV CHROME_BIN=/usr/bin/chromium-browser
ENV CHROME_OPTS="--no-sandbox --headless --disable-gpu --disable-dev-shm-usage"

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Copy application code
COPY . .

# Ensure scripts in .local are usable
ENV PATH=/root/.local/bin:$PATH

# Default command to run tests
CMD ["pytest"]