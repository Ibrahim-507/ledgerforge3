# LedgerForge v1.0.0-rc1: how to run it (for a new person)

You need: Git and Docker Desktop. Nothing else is installed on your computer.

## 1. Get the code
```powershell
git clone https://github.com/Ibrahim-507/ledgerforge.git ledgerforge-clean
cd ledgerforge-clean
git checkout v1.0.0-rc1
```

## 2. Create your private settings file
The repository never contains a secret. You make your own:
```powershell
Copy-Item .env.example .env
python -c "import secrets; print(secrets.token_urlsafe(48))"
```
Open `.env` and replace the three `change-me...` values: the secret key (use the command output), a database password and a demo password.
`.env` is ignored by git and by Docker, so it never leaves your computer.

## 3. Start everything with one command
```powershell
docker compose up --build
```
The first start takes a few minutes: it builds the image, then seeds the data (about 30 seconds). Wait for a line like `starting the API on port 8000`.
Services: `api` (the web API), `worker` (runs background jobs), `db` (PostgreSQL), `redis` (the queue).

Check it is healthy (in a second terminal): `docker compose ps` shows `healthy` for api, db and redis.

## 4. Use it
- Login page: http://localhost:8000/
- API documentation: http://localhost:8000/docs (every API route is under `/api/v1`)
- Demo usernames (the password is the one you set as DEMO_PASSWORD):
  ```powershell
  docker compose logs api | Select-String "ADMIN|HR  |EMPLOYEE"
  ```

## 5. Run the 18-month payroll in the background
In `/docs` (log in, click Authorize, paste the token):
1. `POST /api/v1/jobs/payroll-process` as an HR or Admin user with `{"first": "2025-04", "last": "2026-09"}`. It answers at once with a `job_id`.
2. `GET /api/v1/jobs/{job_id}` shows `status`, `done`, `total` and `percent` while the worker runs. Watch the worker: `docker compose logs worker`.
3. `POST /api/v1/jobs/payroll-approve` as an **Admin who is not the person who started step 1** posts the months to the ledger (add `"pay": true` to pay them).

## 6. Stop
`docker compose down` stops it and keeps the data. `docker compose down -v` also deletes the data.

## Run the tests (no Docker)
```powershell
pip install -r requirements-dev.txt
cp -r seed data          # PowerShell: Copy-Item seed data -Recurse
python -m pytest -q --cov=app --cov-report=term-missing
```

## What the automatic test run protects
`.github/workflows/tests.yml` runs on every push and pull request. It runs all tests with coverage and builds the Docker image, then
checks that the image contains no `.env`, no `.secret_key` and no database file. It protects the main branch from changes that break
payroll or the ledger, that open a route without a login, or that leak a secret into the image: the mistake is caught in minutes,
before it is merged or deployed.

## Known limits of this release candidate
- The ledger, payroll and invoice store is a SQLite file on a Docker volume (shared by `api` and `worker`). PostgreSQL holds the employee data.
  Moving the ledger to PostgreSQL is future work.
- Demo users share one demo password. Real use would send reset links.
- No login attempt limits, refresh tokens or MFA yet.
