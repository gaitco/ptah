FROM dart:stable AS build
WORKDIR /app
COPY pubspec.* ./
RUN dart pub get
COPY . .
# Note: bin/maat.dart boots the full application, so this stage needs to
# succeed with no .env and no reachable database. If that stops holding, build
# the CSS in CI instead and COPY public/ straight in.
# Compile CSS with the Tailwind standalone binary. Downloads it once (~80 MB);
# Docker caches this layer.
RUN dart run bin/maat.dart tailwind --minify
RUN dart pub get --offline && dart build cli --target=bin/server.dart --output=build

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/build/bundle /app
COPY --from=build /app/public /app/public
WORKDIR /app
ENV APP_ENV=production APP_DEBUG=false APP_HOST=0.0.0.0 APP_PORT=8000
EXPOSE 8000
CMD ["/app/bin/server"]
