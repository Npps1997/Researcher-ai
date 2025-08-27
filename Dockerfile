FROM python:3.13

WORKDIR /app

RUN apt-get update && apt-get install -y wget curl libssl-dev libclang-dev pkg-config ca-certificates

RUN curl -fSL -o tectonic.tar.gz https://github.com/tectonic-typesetting/tectonic/releases/download/tectonic-0.15.0/tectonic-0.15.0-x86_64-unknown-linux-gnu.tar.gz \
 && tar -xzf tectonic.tar.gz \
 && mv tectonic-0.15.0-x86_64-unknown-linux-gnu/tectonic /usr/local/bin/tectonic \
 && chmod +x /usr/local/bin/tectonic \
 && rm -rf tectonic.tar.gz tectonic-0.15.0-x86_64-unknown-linux-gnu

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

EXPOSE 8501

CMD ["streamlit", "run", "frontend.py", "--server.port", "8501", "--server.address", "0.0.0.0"]
