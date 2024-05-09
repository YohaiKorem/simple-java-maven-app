FROM maven:3.9.0 as build
WORKDIR /app
COPY . /app
RUN mvn -B -DskipTests clean package

FROM maven:3.9.0 as test
WORKDIR /app
COPY --from=build /app /app
RUN mvn test

FROM openjdk:17-jdk-alpine as deliver
WORKDIR /app
COPY ./scripts/deliver.sh /app/deliver.sh
CMD ["bash", "/app/deliver.sh"]
