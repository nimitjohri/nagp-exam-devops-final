FROM tomcat:alpine
RUN wget -O /usr/local/tomcat/webapps/nimitjohri-feature.war http://192.168.1.7:8081/artifactory/nagp-devops-exam-final/com/example/feature/demosampleapplication/1.0.0-SNAPSHOT/demosampleapplication-1.0.0-SNAPSHOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]