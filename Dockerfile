# Konverta Pro — Railway build. Upload this Dockerfile and konverta-source.zip together.
FROM python:3.12-slim-bookworm
ENV PYTHONDONTWRITEBYTECODE=1 PYTHONUNBUFFERED=1 DENO_INSTALL=/usr/local CONVERTER_STORAGE=/app/downloads
RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg curl unzip ca-certificates \
    && rm -rf /var/lib/apt/lists/*
RUN curl -fsSL https://deno.land/install.sh | sh && deno --version
WORKDIR /app
COPY konverta-source.zip /tmp/konverta-source.zip
RUN unzip -q /tmp/konverta-source.zip -d /tmp \
    && cp -a /tmp/konverta-pro/. /app/ \
    && rm -rf /tmp/konverta-source.zip /tmp/konverta-pro \
    && pip install --no-cache-dir -r /app/requirements.txt \
    && mkdir -p /app/downloads
EXPOSE 8000
HEALTHCHECK --interval=45s --timeout=10s --start-period=30s \
    CMD curl --fail --silent http://127.0.0.1:${PORT:-8000}/api/health || exit 1
CMD ["sh", "-c", "exec python -m uvicorn app:app --host 0.0.0.0 --port ${PORT:-8000}"]
