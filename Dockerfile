# runtime-only image; код и конфиги приходят томом ./backstage:/app
FROM node:20-bookworm-slim

# node-gyp и sqlite3 для scaffolder/techdocs/лучше-sqlite3
ENV PYTHON=/usr/bin/python3 \
    NODE_ENV=production \
    NODE_OPTIONS="--no-node-snapshot"

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && \
    apt-get install -y --no-install-recommends python3 g++ build-essential libsqlite3-dev && \
    rm -rf /var/lib/apt/lists/*

# запускаем под least-privileged пользователем
USER node
WORKDIR /app

RUN mkdir -p /home/node/.cache/yarn

COPY packages/backend/dist/skeleton.tar.gz ./
RUN tar xzf skeleton.tar.gz && rm skeleton.tar.gz

COPY packages/backend/dist/bundle.tar.gz ./
RUN tar xzf bundle.tar.gz && rm bundle.tar.gz


# Запуск backstage
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
