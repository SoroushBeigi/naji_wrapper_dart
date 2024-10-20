FROM dart:stable AS build

WORKDIR /app
COPY . .
RUN dart pub get
RUN dart compile exe server.dart -o najiwrapper
