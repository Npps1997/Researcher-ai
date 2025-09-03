FROM python:3.13-slim

# Install basic tools
RUN apt-get update && apt-get install -y \
    curl \
    tar \
    && rm -rf /var/lib/apt/lists/*

# Download & install Tectonic prebuilt binary (Linux x86_64-gnu)
RUN curl -L https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic%400.15.0/tectonic-0.15.0-x86_64-unknown-linux-gnu.tar.gz \
    -o /tmp/tectonic.tar.gz \
    && tar -xzf /tmp/tectonic.tar.gz -C /tmp \
    && mv /tmp/tectonic-0.15.0-x86_64-unknown-linux-gnu/tectonic /usr/local/bin/ \
    && chmod +x /usr/local/bin/tectonic \
    && rm -rf /tmp/tectonic*

# Verify installation
RUN tectonic --version

# Set workdir
WORKDIR /app

# Install Python deps
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project files
COPY . .

# Expose Streamlit port
EXPOSE 8501

# Run the Streamlit app
CMD ["streamlit", "run", "frontend.py"]
