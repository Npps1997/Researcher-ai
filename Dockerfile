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

# Download tectonic tarball
RUN curl -LO https://github.com/tectonic-typesetting/tectonic/releases/latest/download/tectonic-x86_64-linux.tar.gz

# List tarball contents to debug folder and files inside
RUN tar -tzf tectonic-x86_64-linux.tar.gz

# Extract tarball
RUN tar -xzf tectonic-x86_64-linux.tar.gz

# List extracted folder(s) and files to identify correct path
RUN ls -l

# Move tectonic binary to /usr/local/bin with inferred folder name
RUN mv tectonic-*/tectonic /usr/local/bin/tectonic

# Make tectonic executable
RUN chmod +x /usr/local/bin/tectonic

# Cleanup tarball and extracted folders
RUN rm -rf tectonic-x86_64-linux.tar.gz tectonic-*

# Install python deps
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy app source code
COPY . .

# Expose port
EXPOSE 8501

# Run streamlit
CMD ["streamlit", "run", "frontend.py", "--server.port", "8501", "--server.address", "0.0.0.0"]
