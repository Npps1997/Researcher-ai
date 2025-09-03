# FROM python:3.13

# WORKDIR /app

# COPY requirements.txt .
# RUN pip install -r requirements.txt

# COPY . .

# EXPOSE 8501

# CMD ["streamlit", "run", "frontend.py"]

FROM python:3.13-slim

# Install system deps (Rust, Cargo, build tools, fonts, etc.)
RUN apt-get update && apt-get install -y \
    curl \
    build-essential \
    fontconfig \
    libfontconfig1 \
    libssl-dev \
    pkg-config \
    git \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Rust + Cargo
RUN curl https://sh.rustup.rs -sSf | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Tectonic using Cargo
RUN cargo install tectonic

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Expose Streamlit port
EXPOSE 8501

# Run Streamlit
CMD ["streamlit", "run", "frontend.py", "--server.port=8501", "--server.address=0.0.0.0"]
