# Use official Python base image
FROM python:3.9-slim

# Install minimal dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        wget \
        unzip && \
    rm -rf /var/lib/apt/lists/*

# Download and install Chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends ./google-chrome-stable_current_amd64.deb && \
    rm google-chrome-stable_current_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# Download and install chromedriver
RUN CHROME_VERSION=$(google-chrome --version | cut -d ' ' -f 3) && \
    CHROME_MAJOR_VERSION=$(echo $CHROME_VERSION | cut -d '.' -f 1) && \
    wget -q https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION} -O chromedriver_version.txt && \
    CHROMEDRIVER_VERSION=$(cat chromedriver_version.txt) && \
    wget -q https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /usr/local/bin/ && \
    chmod +x /usr/local/bin/chromedriver && \
    rm chromedriver_linux64.zip chromedriver_version.txt

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV CHROME_OPTS="--no-sandbox --disable-dev-shm-usage --headless"

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