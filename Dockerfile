FROM maven:3.9.0 as build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn  clean package
ARG VERSION=1.0.0
RUN mvn -B versions:set -Dnewversion=1.0.0
FROM maven:3.9.0 as test
WORKDIR /app
COPY --from=build /app /app
RUN mvn test

FROM openjdk:17-jdk-alpine as deliver
WORKDIR /app
COPY --from=build /app/target/my-app-1.0-SNAPSHOT.jar /app/app.jar
# COPY ./scripts/deliver.sh /app/deliver.sh
EXPOSE 5000
CMD java -jar app.jar
