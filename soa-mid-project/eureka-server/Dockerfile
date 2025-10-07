# Build stage
FROM maven:3.9-eclipse-temurin-17-alpine AS build

# First install parent POM
WORKDIR /build
COPY pom.xml pom.xml
RUN mvn install -N

# Now build the service
WORKDIR /app
COPY eureka-server/pom.xml .
COPY eureka-server/.mvn .mvn

# Download dependencies
RUN mvn dependency:go-offline -B || true

# Copy source code and build
COPY eureka-server/src src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Install curl for healthcheck
RUN apk add --no-cache curl

# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8761

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
