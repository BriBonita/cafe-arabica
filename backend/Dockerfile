FROM python:3.11-slim

# Install system dependencies required by mysqlclient
RUN apt-get update && apt-get install -y \
    gcc \
    pkg-config \
    default-libmysqlclient-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

# Logs directory
RUN mkdir -p /app/logs

EXPOSE 5000

CMD ["python", "app.py"]
