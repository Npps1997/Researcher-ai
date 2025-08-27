FROM python:3.13

WORKDIR /app

# Install dependencies for tectonic (Debian/Ubuntu base assumed)
RUN apt-get update && apt-get install -y wget curl libssl-dev libclang-dev pkg-config ca-certificates
# Download and install tectonic binary
RUN curl -LO https://github.com/tectonic-typesetting/tectonic/releases/latest/download/tectonic-x86_64-linux.tar.gz && \
    tar -xzf tectonic-x86_64-linux.tar.gz && \
    mv tectonic /usr/local/bin/ && \
    chmod +x /usr/local/bin/tectonic && \
    rm -rf tectonic-x86_64-linux.tar.gz

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8501

CMD ["streamlit", "run", "frontend.py", "--server.port", "8501", "--server.address", "0.0.0.0"]
