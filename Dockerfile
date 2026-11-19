# LedgerForge release image. NO secret is copied or set here: every secret arrives as an environment variable when the container starts.
FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    LEDGERFORGE_DATA=/app/seed \
    LEDGERFORGE_DB=/var/lib/ledgerforge/ledgerforge.sqlite \
    LEDGERFORGE_STATE_DIR=/var/lib/ledgerforge

WORKDIR /app

# install dependencies first so Docker can reuse this layer when only the code changes.
# If requirements-lock.txt exists (made with pip freeze from your WORKING environment) it is used: exact versions, no surprises.
COPY requirements-prod.txt requirements-lock.tx[t] ./
RUN if [ -f requirements-lock.txt ]; then pip install --no-cache-dir -r requirements-lock.txt; \
    else pip install --no-cache-dir -r requirements-prod.txt; fi

# the code and the (fictional) seed data. .dockerignore keeps .env, .secret_key, databases, .git and tests OUT of the image.
COPY . .

# run as a normal user, never as root
RUN useradd --create-home --uid 1001 appuser \
    && mkdir -p /var/lib/ledgerforge \
    && chown -R appuser:appuser /var/lib/ledgerforge /app
USER appuser

EXPOSE 8000
HEALTHCHECK --interval=15s --timeout=5s --start-period=90s --retries=5 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=4)" || exit 1

CMD ["python", "-m", "scripts.entrypoint"]
