FROM maven:3.9.0 as build
WORKDIR /app
COPY pom.xml .
COPY src ./src
ARG VERSION
RUN mvn -B versions:set -DnewVersion=$VERSION
RUN mvn  clean package
RUN ls -l /app/target
FROM maven:3.9.0 as test
WORKDIR /app
COPY --from=build /app /app
RUN mvn test
FROM openjdk:17-jdk-alpine as deliver
WORKDIR /app
COPY --from=build /app/target/my-app-$VERSION.jar /app/app.jar
# COPY ./scripts/deliver.sh /app/deliver.sh
EXPOSE 5000
RUN echo yes
CMD java -jar app.jar
