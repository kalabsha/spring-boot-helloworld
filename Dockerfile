# Create a Dockerfile with two stages, 
# - the first stage compiles code and output a jar file, 
# - the second stage run the jar and expose the service with 8080 port.

# https://spring.io/guides/topicals/spring-boot-docker/

# syntax=docker/dockerfile:experimental
FROM maven:3.9.0-eclipse-temurin-8-alpine as build
WORKDIR /workspace/app

# COPY mvnw .
# COPY .mvn .mvn
COPY pom.xml .
COPY src src
COPY configuration configuration

RUN --mount=type=cache,target=/root/.m2 mvn -s ./configuration/settings.xml install -DskipTests

FROM eclipse-temurin:8-jre-alpine

RUN addgroup -S demo && adduser -S demo -G demo

WORKDIR /workspace/app

ARG TARGET_PATH=/workspace/app/target

COPY --from=build ${TARGET_PATH}/*.jar helloworld.jar

USER demo

EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar helloworld.jar"]
