FROM maven:3.9-eclipse-temurin-17-alpine AS build
WORKDIR /app

# Copy parent pom first
COPY ../pom.xml /app/parent-pom.xml

# Copy module pom.xml and files
COPY pom.xml .
COPY src src

# Install parent POM to local repo
RUN mvn install:install-file \
    -Dfile=/app/parent-pom.xml \
    -DgroupId=com.example \
    -DartifactId=soa-mid-project \
    -Dversion=1.0.0 \
    -Dpackaging=pom

# Force Java 17 compilation with explicit settings
RUN mvn clean package -DskipTests \
    -Dmaven.compiler.source=17 \
    -Dmaven.compiler.target=17 \
    -Dmaven.compiler.release=17 \
    -Djava.version=17

FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
CMD ["java", "-jar", "app.jar"]