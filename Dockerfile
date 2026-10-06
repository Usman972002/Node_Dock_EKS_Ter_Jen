FROM node:22-alpine AS base            # Node 20 is end-of-life; 22 is the maintained LTS line
WORKDIR /app                           # all later paths are relative to /app

COPY package*.json ./                  # copy manifests first so the dependency layer is cached
RUN npm ci --omit=dev && npm cache clean --force   # reproducible install, no devDependencies, smaller layer

COPY --chown=node:node src ./src       # app code owned by the non-root user

ENV NODE_ENV=production                # Express and Pino switch to production behaviour
EXPOSE 8000                            # documentation only; matches PORT

USER 1000:1000                         # numeric UID of "node" so Kubernetes can verify runAsNonRoot
CMD ["node", "src/index.js"]           # run directly (not via npm) so SIGTERM reaches Node for graceful shutdown
