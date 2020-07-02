rem 开始安装 dubbo-monitor ...
set workdir=%cd:~0,2%\var\docker
cd /d %workdir%
docker stop monitor
docker rm -f monitor
rd /q /s monitor
md monitor\webapps\dubbo-monitor\WEB-INF\classes
md monitor\logs

java -jar install\zipper.jar u install\dubbo-monitor.war monitor\webapps\dubbo-monitor
copy install\dubbo-monitor-notlinux.properties monitor\webapps\dubbo-monitor\WEB-INF\classes\application.properties

docker run --name monitor -d -p 8787:8080 -p 7960:6060 --restart=always -v %workdir%\monitor\logs:/usr/local/tomcat/logs -v %workdir%\monitor\webapps:/usr/local/tomcat/webapps tomcat:8.5.34
