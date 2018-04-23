# Base image infó: https://github.com/docker-library/repo-info/blob/master/repos/gradle/remote/4.6.0-jdk8-alpine.md
# Használjunk egy olyan base image-t, amiben már alapból van egy olyan gradle készen, ami nekünk kell
# Illetve amiben már van olyan java is készen, ami nekünk kell
# Ezzel drasztikusan csökkenthetjük a build időt, hiszen nem kell semmit letölteni vagy telepíteni ebben a dockerfile-ban
FROM gradle:4.6.0-jdk8-alpine

# a containeren belül rootként csináljunk mindent, ne pedig a default "gradle" nevű userrel
USER root

# ne futtasson a gradle daemont, semmi értelme, hiszen a docker build végén úgyis ki lenne lőve
RUN echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties

# Csináljunk egy ideiglenes mappát a forráskódnak, és egy ideiglenes mappát a konkrét appnak, ami majd futni fog futásidőben
RUN mkdir /opt/app-build && mkdir /opt/app

# másoljuk be a forráskódunkat az ideiglenes mappába
COPY . /opt/app-build

# a containeren belüli(!) gradle segítségével buildeljük fel az appot, és futtassuk le a teszteket is rajta
RUN cd /opt/app-build && $GRADLE_HOME/bin/gradle build

# mivel a legenerált jar fájlon kívül semmire nincs szükségünk futásidőben, ezért azt másoljuk el egy fix helyre, és töröljük ki az ideiglenes mappát
# mert az úgyis csak a helyet foglalná feleslegesen
RUN mv "/opt/app-build/build/libs/docker-0.0.1-SNAPSHOT.jar" /opt/app/app.jar && rm -rf /opt/app-build

# (opcionális, quality of life) hogy az automata docker kliensek (pl kitematic) tudjon róla, hogy milyen portot használ a futó app a containeren belül
EXPOSE 8198

# (opcionális, quality of life) ha `docker exec ...`-kel beléünk a containerbe, akkor melyik mappában legyünk alapból
WORKDIR /opt/app

# mit indítson a containeren belül a docker majd futásidőben
ENTRYPOINT ["java","-Djava.security.egd=file:/dev/./urandom","-Dspring.profiles.active=development","-jar","/opt/app/app.jar"]

