FROM openjdk:11
MAINTAINER Ashutosh Jha
COPY target/spring-petclinic-2.6.0-SNAPSHOT.jar /var/spring-petclinic-2.6.0-SNAPSHOT.jar
CMD ["java","-jar","/var/spring-petclinic-2.6.0-SNAPSHOT.jar"]
