FROM python:3.13-slim

# Install system deps + Tectonic
RUN apt-get update && apt-get install -y \
    tectonic \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy source code
COPY . .

# Expose port (for Streamlit)
EXPOSE 8501

# Run the app
CMD ["streamlit", "run", "frontend.py", "--server.port=8501", "--server.address=0.0.0.0"]
