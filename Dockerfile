# Create a Dockerfile with two stages, 
# - the first stage compiles code and output a jar file, 
# - the second stage run the jar and expose the service with 8080 port.

# https://spring.io/guides/topicals/spring-boot-docker/

FROM eclipse-temurin:17-jdk-alpine as build
WORKDIR /workspace/app

COPY mvnw .
COPY .mvn .mvn
COPY pom.xml .
COPY src src
COPY configuration configuration

# RUN mkdir -p target/dependency && (cd target/dependency; jar -xf ../*.jar)

FROM eclipse-temurin:17-jre-alpine

# VOLUME /tmp
WORKDIR /workspace/app

ARG TARGET_PATH=/workspace/app/target
# ARG DEPENDENCY=/workspace/app/target/dependency

# COPY --from=build ${DEPENDENCY}/BOOT-INF/lib /app/lib
# COPY --from=build ${DEPENDENCY}/META-INF /app/META-INF
# COPY --from=build ${DEPENDENCY}/BOOT-INF/classes /app

COPY --from=build ${TARGET_PATH}/*.jar helloworld.jar


EXPOSE 8080
# ENTRYPOINT ["java","-cp","app:app/lib/*","hello.Application"]
ENTRYPOINT ["sh", "-c", "java ${JAVA_OPTS} -jar helloworld.jar"]
