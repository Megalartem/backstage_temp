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

# опционально: отдельный кеш для yarn (ускоряет первый старт)
RUN mkdir -p /home/node/.cache/yarn

# маленький entrypoint, который сам поставит deps/соберёт, если нужно
COPY --chown=node:node docker/entrypoint.sh /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

# Запуск backstage
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
