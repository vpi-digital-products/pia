# syntax=docker/dockerfile:1

# --- Stage 1: build the Angular app --------------------------------------
FROM node:22.20.0-alpine AS build

# Enable Corepack so the exact Yarn version pinned in package.json is used.
RUN corepack enable

WORKDIR /app

# Install dependencies first for better layer caching.
COPY package.json yarn.lock .yarnrc.yml ./
RUN yarn install --immutable

# Copy the rest of the sources and build the production bundle.
COPY . .
RUN yarn build --configuration production

# --- Stage 2: serve the static bundle with nginx -------------------------
FROM nginx:1.27-alpine AS runtime

# The @angular/build:application builder emits into dist/<project>/browser.
COPY --from=build /app/dist/pia-angular/browser /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Runtime config generation: writes assets/config.json from env vars at boot.
# The nginx image auto-runs /docker-entrypoint.d/*.sh before starting nginx.
COPY docker-entrypoint.d/40-pia-runtime-config.sh /docker-entrypoint.d/40-pia-runtime-config.sh
RUN chmod +x /docker-entrypoint.d/40-pia-runtime-config.sh

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
