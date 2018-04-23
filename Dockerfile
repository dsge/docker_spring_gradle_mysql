FROM gradle:alpine
USER root
RUN mkdir /opt/app && cd /opt/app
WORKDIR /opt/app
COPY . /opt/app
RUN chmod +x gradlew
RUN ./gradlew assemble
#RUN find -name \*.jar
#ADD build/libs/vote-service-0.0.1-SNAPSHOT.jar app.jar
RUN /bin/sh -c 'touch /app.jar'
#ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-Dspring.profiles.active=container","-jar","app.jar"]
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-Dspring.profiles.active=development","-jar","build/libs/docker-0.0.1-SNAPSHOT.jar"]

