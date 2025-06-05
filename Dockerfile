# Use official Python base image
FROM python:3.9-slim as builder

# Download static wget and unzip binaries
RUN mkdir -p /opt/bin && \
    wget -q -O /opt/bin/wget https://github.com/moparisthebest/static-curl/releases/download/v7.88.1/wget && \
    wget -q -O /opt/bin/unzip https://github.com/moparisthebest/static-curl/releases/download/v7.88.1/unzip && \
    chmod +x /opt/bin/wget /opt/bin/unzip

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1
ENV PATH="/opt/bin:${PATH}"

# Download and install Chrome
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
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

# Runtime stage
FROM python:3.9-slim

# Copy binaries from builder
COPY --from=builder /opt /opt

# Set environment variables
ENV PATH="/opt/bin:${PATH}"
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