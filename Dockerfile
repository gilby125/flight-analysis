# First stage - get wget and unzip from a base image that has them
FROM debian:bullseye-slim as downloader

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget unzip && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /opt/bin && \
    wget -q -O /opt/bin/wget https://github.com/moparisthebest/static-curl/releases/download/v7.88.1/wget && \
    wget -q -O /opt/bin/unzip https://github.com/moparisthebest/static-curl/releases/download/v7.88.1/unzip && \
    chmod +x /opt/bin/wget /opt/bin/unzip

# Second stage - main build
FROM python:3.9-slim

# Copy static binaries from downloader stage
COPY --from=downloader /opt/bin/wget /opt/bin/wget
COPY --from=downloader /opt/bin/unzip /opt/bin/unzip
ENV PATH="/opt/bin:${PATH}"

# Download and install Chrome
RUN mkdir -p /opt/chrome && \
    wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    dpkg -x google-chrome-stable_current_amd64.deb /opt/chrome && \
    rm google-chrome-stable_current_amd64.deb

# Download and install chromedriver
RUN CHROME_VERSION=$(/opt/chrome/opt/google/chrome/chrome --version | cut -d ' ' -f 3) && \
    CHROME_MAJOR_VERSION=$(echo $CHROME_VERSION | cut -d '.' -f 1) && \
    wget -q https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION} -O chromedriver_version.txt && \
    CHROMEDRIVER_VERSION=$(cat chromedriver_version.txt) && \
    wget -q https://chromedriver.storage.googleapis.com/${CHROMEDRIVER_VERSION}/chromedriver_linux64.zip && \
    unzip chromedriver_linux64.zip && \
    mv chromedriver /opt/bin/ && \
    chmod +x /opt/bin/chromedriver && \
    rm chromedriver_linux64.zip chromedriver_version.txt

# Set environment variables
ENV CHROME_OPTS="--no-sandbox --disable-dev-shm-usage --headless"
ENV CHROME_BIN="/opt/chrome/opt/google/chrome/chrome"

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --user -r requirements.txt

# Copy application code
COPY . .

# Ensure scripts in .local are usable
ENV PATH="/root/.local/bin:${PATH}"

# Default command to run tests
CMD ["pytest"]