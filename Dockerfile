FROM python:3.13

WORKDIR /app

# Install necessary system packages for tectonic and utilities
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    libssl-dev \
    libclang-dev \
    pkg-config \
    ca-certificates

# Download and install tectonic from official GitHub releases
RUN curl -LO https://github.com/tectonic-typesetting/tectonic/releases/latest/download/tectonic-x86_64-linux.tar.gz && \
    tar -xzf tectonic-x86_64-linux.tar.gz && \
    mv tectonic-*/tectonic /usr/local/bin/tectonic && \
    chmod +x /usr/local/bin/tectonic && \
    rm -rf tectonic-x86_64-linux.tar.gz tectonic-*

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the rest of the app code
COPY . .

# Expose Streamlit default port
EXPOSE 8501

# Run Streamlit, binding to all interfaces and using default port
CMD ["streamlit", "run", "frontend.py", "--server.port", "8501", "--server.address", "0.0.0.0"]
