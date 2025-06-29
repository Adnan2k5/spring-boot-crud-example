FROM maven:3.6.3-openjdk-8-slim AS build

WORKDIR /app
COPY pom.xml .

RUN mvn dependency:go-offline -B

COPY src ./src

RUN mvn clean package -DskipTests

FROM openjdk:8-jre-alpine

RUN apk --no-cache add curl

RUN addgroup -g 1001 -S appuser && \
    adduser -u 1001 -S appuser -G appuser

WORKDIR /app
COPY --from=build /app/target/*.jar app.jar

RUN mkdir -p /app/logs && chown -R appuser:appuser /app
USER appuser

EXPOSE 9191

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:9191/actuator/health || exit 1

ENV JAVA_OPTS="-Xmx512m -Xms256m -Djava.security.egd=file:/dev/./urandom"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
