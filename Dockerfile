FROM centos

MAINTAINER aksarav@middlewareinventory.com

RUN mkdir /opt/tomcat/

WORKDIR /opt/tomcat
RUN curl -O https://downloads.apache.org/tomcat/tomcat-8/v8.5.65/bin/apache-tomcat-8.5.65.tar.gz
#RUN curl -O https://www-eu.apache.org/dist/tomcat/tomcat-8/v8.5.65/bin/apache-tomcat-8.5.65.tar.gz
RUN tar -xvf apache-tomcat-8.5.65.tar.gz
RUN mv apache-tomcat-8.5.65/* /opt/tomcat/
RUN yum -y install java
RUN java -version

WORKDIR /opt/tomcat/webapps
#RUN curl -O -L https://github.com/AKSarav/SampleWebApp/raw/master/dist/SampleWebApp.war
RUN curl -O -L https://github.com/krishnamaram2/binary-code/raw/master/binaries/Student.war

EXPOSE 8080

CMD ["/opt/tomcat/bin/catalina.sh", "run"]
