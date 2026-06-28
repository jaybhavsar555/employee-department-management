# Use Flutter stable; pubspec SDK is ^3.12.0 to match Docker image
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

COPY pubspec.yaml ./
RUN flutter pub get

COPY . .

# Relative URL: browser calls nginx, nginx proxies /api/* to the backend container
ARG API_BASE_URL=/api/v1
RUN flutter build web --release --dart-define=API_BASE_URL=${API_BASE_URL}

# Stage 2 — serve with nginx
FROM nginx:1.27-alpine

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
