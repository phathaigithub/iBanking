# Build stage
FROM maven:3.9-eclipse-temurin-17-alpine AS build

# First install parent POM
WORKDIR /build
COPY pom.xml pom.xml
RUN mvn install -N

# Now build the service
WORKDIR /app
COPY api-gateway/pom.xml .
COPY api-gateway/.mvn .mvn

# Download dependencies
RUN mvn dependency:go-offline -B || true

# Copy source code and build
COPY api-gateway/src src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8086

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
