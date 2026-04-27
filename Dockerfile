FROM eclipse-temurin:25-jdk AS builder


WORKDIR /app
COPY . .
RUN ./gradlew build -x test --no-daemon



FROM eclipse-temurin:25-jdk AS jre-builder
RUN jlink \
    --add-modules java.base,java.naming,java.logging,java.management,java.security.jgss,java.desktop,java.xml,java.instrument \
    --strip-debug \
    --no-man-pages \
    --no-header-files \
    --compress=2 \
    --output /jre-minimal

FROM debian:bookworm-slim
copy --from=jre-builder /jre-minimal /opt/java
copy --from=builder /app/build/libs/app.jar /app/app.jar
ENV PATH ="/opt/java/bin:$PATH"
ENV JAVA_HOME="opt/java"
EXPOSE 8080
CMD ["/opt/java/bin/java", "-jar", "/app/app.jar"]
