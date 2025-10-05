# Build stage
FROM maven:3.9-eclipse-temurin-17-alpine AS build

# First install parent POM
WORKDIR /build
COPY pom.xml pom.xml
RUN mvn install -N

# Build common-library first
COPY common-library common-library
RUN cd common-library && mvn clean install -DskipTests

# Now build the service
WORKDIR /app
COPY tuition-service/pom.xml .
COPY tuition-service/.mvn .mvn

# Download dependencies
RUN mvn dependency:go-offline -B || true

# Copy source code and build
COPY tuition-service/src src
RUN mvn clean package -DskipTests

# Runtime stage
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

# Copy jar from build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port
EXPOSE 8083

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
