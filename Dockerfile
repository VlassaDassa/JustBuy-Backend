FROM python:3.11.9-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

COPY requirements.txt requirements.docker.txt ./

RUN python -m pip install --no-cache-dir --upgrade pip && python -m pip install --no-cache-dir -r requirements.docker.txt

COPY . .

RUN mkdir -p /seed/media /data && \
    if [ -f /app/test_api/db.sqlite3 ]; then cp /app/test_api/db.sqlite3 /seed/db.sqlite3; fi && \
    if [ -d /app/test_api/media ]; then cp -a /app/test_api/media/. /seed/media/; fi

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh && chmod +x /usr/local/bin/docker-entrypoint.sh

WORKDIR /app/test_api

EXPOSE 8000

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["gunicorn", "test_api.wsgi:application", "--bind", "0.0.0.0:8000", "--workers", "2", "--timeout", "60", "--access-logfile", "-", "--error-logfile", "-"]
