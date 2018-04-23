# docker_spring_gradle_mysql [![Build Status](https://travis-ci.org/dsge/docker_spring_gradle_mysql.svg?branch=master)](https://travis-ci.org/dsge/docker_spring_gradle_mysql)

Mysql adatbázis indítása dockeren belül (opcionális, csak ha nincs már meglevő db-d)
---

```
$ docker run --name mysql1 -e MYSQL_ROOT_PASSWORD=ROOT. -e MYSQL_DATABASE=myapp -d mysql:5.7
```

Ahol:

- `mysql1`: a mysql szervert ilyen néven indítsa el a docker
- `ROOT.`: mysql-ben a `root` nevű userhez tartozó jelszó
- `myapp`: mysql-ben legyen létrehozva alapból egy ilyen nevű adatbázis (opcionális, de megspórolja a manuális létrehozást)

További infók: https://hub.docker.com/_/mysql/

Grafikus hozzáférés a futó mysql szerverünkhoz adminerrel
---

```
$ docker run --name adminer --link mysql1:db -p 8181:8080 adminer
```

Ahol:

- `mysql1`: a mysql szerverünket ilyen néven ismeri a docker, ez legyen hozzákapcsolva a futtatandó adminer instance-unkhoz
- `8181`: ilyen porton akarjuk elérni majd a böngészőnkben az adminert

Windowson `docker-machine ip` command segítségével kaphatjuk meg a futó docker host ip-jét, ezt kell beírni a böngészőbe: `http:IP_CIM:8181`

Adminerben:

- host: `db`
- db name: (üresen lehet hagyni)
- user: `root`
- pass: `ROOT.`

További infók: https://hub.docker.com/_/adminer/


Container buildelése CLI-ből (manuális buildhez vagy CI-hez)
---

```
$ docker build -t mycompany/myapp .
```

Ahol:

- `mycompany/myapp` a készítendő image neve
- `.` útvonal a dockerfile-hoz

Ez lefuttatja a teszteket is, és failel, ha nem jók. Nem megszokott a `docker build` lépésben tesztelni, de most nem tudok jobbat hirtelen.
Ez baromi rossz lesz olyan tesztnél, amihez kellene egy futó mysql instance, hiszen az buildkor nincsen. Az csak futásidőben lesz majd. Hogy mit lehet tenni? Lásd "Todo" rész lentebb.

Container futtatása CLI-ből (manuális buildhez vagy CI-hez)
---

```
$ docker run -p 3000:8198 --env DATABASE_HOST=db --env DATABASE_USER=root --env DATABASE_PASSWORD=ROOT. --env DATABASE_NAME=myapp --env DATABASE_PORT=3306 --name springapp1 --link mysql1:db mycompany/myapp 
```

Ahol:
- `3000`: ilyen porton fogjuk elérni a futó appot
- `db`: ilyen néven linkeltük hozzá a mysql-t futtató container (ha nem linkelt szerver van, akkor ide a szerver ip-je jöhet)
- `root`: ilyen userrel érheti el a mysql db-t (opcionális, default: `user`)
- `ROOT.`: ez a mysql user jelszava az adatbázishoz (opcionális, default: `password`)
- `myapp`: az ilyen nevű adatbázist kell használnia az appnak a mysql szerveren (opcionális, default: `demo`)
- `3306`: adatbázis port (default: `3306`, ami amúgy a mysql defaultja is)
- `springapp1`: ilyen néven akarjuk létrehozni a containert
- `mysql1`: ilyen néven fut a mysql containerünk, amit használni kellene (opcionális, csak ha dockeren belül futtatott mysql szervert használunk)
- `mycompany/myapp`: ilyen tag-gel (`-t`) buildeltük le az image-t, ebből akarunk egy példányt (containert) futtatni

Windowson `docker-machine ip` command segítségével kaphatjuk meg a futó docker host ip-jét, ezt kell beírni a böngészőbe: `http:IP_CIM:3000`

IntelliJ Idea beállítása, hogy a Run gomb lebuildelje és lefuttassa az appunkat, és ne kelljen manuálisan
---

Guide: https://www.jetbrains.com/help/idea/docker.html

Ugyanazokat kell felvinni, mint amit a CLI-s futtatásnál. Csak itt van rá GUI. Így néz ki a végeredmény:
![így néz ki](https://i.imgur.com/Qc11xGI.png)

Ez után a Run gomb újra fogja buildelni az image-t, majd kitörli az előző ugyanilyen nevű containert, és indít belőle egy új instance-t.

Tesztek lefuttatása kézzel, build után
---

Ilyesmit ez nem fog tudni, hiszen kitöröljük a forrásfájlokat build közben.

Coverage report
---
Build közben lehet generáltatni, és elküldeni tetszőleges API-ra. De ilyet ez most per pillanat nem tud.

Belépés a futó containerbe:
---

```
$ docker exec -it springapp1 sh
```

Ahol:
- `sh` a végrehajtandó parancs neve, de más is lehet az `sh`-n kívül (a workdir az az `/opt/app`)

Adatbázis inicializáció / sémamódosítások lefuttatása egy más futó adatbázison
---

A futó app containerbe be lehet lépni:
```
$ docker exec -it springapp1 sh
```

Így ha van olyan command (ezt én nem tudom), ami azt mondja a futó appnak, hogy a hozzá kapcsolt mysql adatbázist most frissítse, akkor ezzel ki lehet neki adni.

Tehát productionben a normál futó appokon kívül kell pontosan egyet indítani csak azért, hogy utána azon belül lefuttassuk a sémamódosítást elvégző parancsot.

Mivel nem ismerem a parancsot, ami ezt csinálná, ezért nem tudok konkrét példát mutatni itt. 


Todo a jövőben
---

- Tesztelés refaktorálása, hogy külön step legyen, ne legyen egyben a buildeléssel (CI miatt fontos, de én nem tudom sajnos, hogy ezt hogy lehet megtenni egy ilyen appnál)
- A minden buildhez a gradle által letöltött dolgokat lehet cache-elni volume-ként, ha tudjuk hogy az image-n belül melyik mappába tölti le ezeket pontosan a gradle.
- Mivel a gradle-ra igazából nincs is futás időben szükség, és feleslegesen foglalja a helyet, ezért másik base image kellene, amiben buildelés után csak a java binary marad meg, a gradle nem. Én nem tudom, hogy kell ezt megcsinálni (jól). 
