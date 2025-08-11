from python:3.11-slim

env pythonunbuffered=1

copy --from=ghcr.io/astral-sh/uv:0.5.11 /uv /uvx /bin/

env uv_compile_byte=1

env uv_link_mode=copy

# change the working directory to the `app` directory
workdir /app

env path="/app/.venv/bin:$path"

copy ./pyproject.toml ./uv.lock ./.python-version /app/

# install dependencies
run --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev

# copy the project into the image
copy ./app /app/app

# sync the project
run --mount=type=cache,target=/root/.cache/uv \
    uv sync --frozen --no-dev

cmd ["fastapi", "dev", "app/main.py", "--host", "0.0.0.0"]