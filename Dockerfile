FROM maven:3.9-eclipse-temurin-17-alpine AS build

WORKDIR /app

COPY pom.xml .

RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn clean package -DskipTests -B

FROM eclipse-temurin:17-jre-alpine AS runtime

RUN addgroup -S mecaniqa && adduser -S mecaniqa -G mecaniqa

WORKDIR /app

COPY --from=build /app/target/app.jar app.jar

USER mecaniqa

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]