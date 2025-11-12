# Django Starter Template

A reusable Django starter you can clone for any backend (Gym, Inventory, HR, etc.).  
Includes PostgreSQL, environment-specific settings, and Docker Compose for easy local, staging, and production runs.

## Features

- Django 5 + PostgreSQL
- Settings split by environment: `local`, `dev`, `prod`
- `.env` configuration (via `django-environ`)
- Works **with Docker** (Compose) or **without Docker** (venv)
- Example app with a health endpoint: `GET /api/ping/`
- Ready for static/media directories and future apps under `apps/`

## Tech Stack

- Python 3.12
- Django 5.x
- PostgreSQL 16
- Gunicorn + UvicornWorker (ASGI) for production
- Docker & Docker Compose (optional)

## Project Structure

```
.
├─ apps/
│  └─ api/                  # example app (you can add gym, inventory, hr, etc.)
│     ├─ urls.py
│     └─ views.py
├─ core/
│  ├─ urls.py
│  ├─ asgi.py
│  ├─ wsgi.py
│  └─ settings/
│     ├─ base.py
│     ├─ local.py
│     ├─ dev.py
│     └─ prod.py
├─ docker/
│  └─ wait_for_db.sh
├─ templates/               # optional
├─ static/                  # optional
├─ media/                   # optional
├─ manage.py
├─ requirements.txt
├─ Dockerfile
├─ compose.yml
├─ compose.dev.yml
├─ .env.example
└─ .gitignore
```

## Requirements

- **Without Docker**
  - Python 3.12+
  - PostgreSQL 14+ (16 recommended)
- **With Docker**
  - Docker Engine
  - Docker Compose

---

## 1) Environment Configuration

Copy and adjust your environment file:

```bash
cp .env.example .env
```

**.env keys (used by the settings files):**
```
# Which settings module to use
DJANGO_SETTINGS_MODULE=core.settings.local

# Django
SECRET_KEY=change-me
ALLOWED_HOSTS=localhost,127.0.0.1

# Database (values change per environment)
DB_NAME=gym_local
DB_USER=gym_user
DB_PASSWORD=gym_pass
DB_HOST=127.0.0.1
DB_PORT=5432
```

> For **Docker**, set `DB_HOST=db` (the service name in Compose).

---

## 2A) Run WITHOUT Docker (local development)

1) Create a PostgreSQL role and database (macOS/Linux shell; for Windows use pgAdmin or psql):

```bash
createuser -P gym_user
createdb -O gym_user gym_local
```

2) Create and activate a virtualenv, then install deps:

```bash
python -m venv .venv
source .venv/bin/activate        # Windows: .venv\Scripts\activate
pip install -r requirements.txt
```

3) Make sure your `.env` has:
```
DJANGO_SETTINGS_MODULE=core.settings.local
DB_NAME=gym_local
DB_USER=gym_user
DB_PASSWORD=gym_pass
DB_HOST=127.0.0.1
DB_PORT=5432
```

4) Migrate and run:

```bash
python manage.py migrate
python manage.py createsuperuser   # optional
python manage.py runserver
```

Visit: [http://localhost:8000/api/ping/](http://localhost:8000/api/ping/) → `{"status":"ok"}`

---

## 2B) Run WITH Docker (development)

This spins up **Postgres** and the **web app** together.

```bash
cp .env.example .env
# in .env, set:
# DJANGO_SETTINGS_MODULE=core.settings.dev
# DB_HOST=db
docker compose -f compose.yml -f compose.dev.yml up --build
```

First-time initialization (run after containers are up):

```bash
docker compose exec web python manage.py migrate
docker compose exec web python manage.py createsuperuser
```

Visit: [http://localhost:8000/api/ping/](http://localhost:8000/api/ping/)

> Stop: `docker compose down`  
> Stop and remove data (DB volume): `docker compose down -v` (⚠️ deletes DB data)

---

## 2C) Run WITH Docker (production / VPS)

1) Point your `.env` to prod:

```
DJANGO_SETTINGS_MODULE=core.settings.prod
SECRET_KEY=<strong-secret>
ALLOWED_HOSTS=your-domain.com,IP
DB_NAME=app
DB_USER=app_user
DB_PASSWORD=<password>
DB_HOST=db
DB_PORT=5432
```

2) Start:

```bash
docker compose up -d --build
docker compose exec web python manage.py migrate
docker compose exec web python manage.py collectstatic --noinput
docker compose exec web python manage.py createsuperuser
```

3) Put **Nginx/Caddy** in front as a reverse proxy for HTTPS (optional but recommended).

---

## Common Commands

**Without Docker**
```bash
python manage.py makemigrations
python manage.py migrate
python manage.py createsuperuser
python manage.py collectstatic --noinput
python manage.py shell
```

**With Docker**
```bash
docker compose up -d --build
docker compose ps
docker compose logs -f web
docker compose exec web python manage.py migrate
docker compose exec web python manage.py collectstatic --noinput
docker compose down
```

---

## Adding New Apps (reusing the template)

1) Create your domain app, e.g. `apps/gym`, `apps/inventory`, `apps/hr`.
2) Add the app to `INSTALLED_APPS` in `core/settings/base.py`.
3) Wire its routes in `core/urls.py` with `include("apps.your_app.urls")`.
4) Run migrations and build your APIs or templates.

> You can keep multiple apps in the same project; versions of your API should be namespaced (`/api/v1/...`).

---

## Health Check

- Basic health endpoint: `GET /api/ping/` → `{"status":"ok"}`

---

## Troubleshooting

- **`psycopg`/`libpq` errors (no Docker)**  
  Ensure PostgreSQL client libs are installed; on Debian/Ubuntu:  
  `sudo apt install libpq-dev python3-dev build-essential`

- **Cannot connect to DB**  
  Check `DB_HOST`, `DB_PORT`, and credentials. In Docker, `DB_HOST=db`.

- **Static files not appearing in production**  
  Run `collectstatic` and ensure your reverse proxy serves `/static/` and `/media/`.

- **Volume data persists**  
  Use `docker compose down -v` to remove DB data (only if you intend to).

---

## License / Notes

- Add your preferred license in `LICENSE`.
- Do **not** commit real secrets; keep only `.env.example` in git.

---

**Happy building!**  
This template is purposefully minimal so you can add: DRF + JWT + CORS, Celery/Redis, S3 media, etc., when you need them.
