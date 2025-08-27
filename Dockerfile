FROM python:3.13

WORKDIR /app

# Install necessary system packages
RUN apt-get update && apt-get install -y \
    wget \
    curl \
    libssl-dev \
    libclang-dev \
    pkg-config \
    ca-certificates

# Download tectonic v0.15.0 release tarball, verify and extract
RUN curl -fSL -o tectonic-x86_64-linux.tar.gz \
    https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic@0.15.0/tectonic-x86_64-linux.tar.gz && \
    tar -tzf tectonic-x86_64-linux.tar.gz && \
    tar -xzf tectonic-x86_64-linux.tar.gz

# List extracted files (debug)
RUN ls -l tectonic-*

# Move tectonic binary to /usr/local/bin
RUN mv tectonic-*/tectonic /usr/local/bin/tectonic && \
    chmod +x /usr/local/bin/tectonic

# Clean-up
RUN rm -rf tectonic-x86_64-linux.tar.gz tectonic-*

# Install Python dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app source code
COPY . .

# Expose port
EXPOSE 8501

# Run the Streamlit app
CMD ["streamlit", "run", "frontend.py", "--server.port", "8501", "--server.address", "0.0.0.0"]
