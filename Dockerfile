# Use official Selenium Python image with Chrome pre-installed
FROM selenium/python:4.8.0

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