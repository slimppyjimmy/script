# 开始安装 dubbo-monitor ...
docker stop monitor
docker rm -f monitor

SYSTEM=`uname -s`
#使用当前完整路径作为安装路径（docker的-v参数不能使用带有~的或相对的路径）
workdir=`pwd`
cd ${workdir}
rm -rf monitor
mkdir -p monitor/webapps/dubbo-monitor/WEB-INF/classes
mkdir -p monitor/logs

unzip install/dubbo-monitor.war -d monitor/webapps/dubbo-monitor
if [ "$SYSTEM" == "Linux" ] ; then 
	\cp -f install/dubbo-monitor-linux.properties monitor/webapps/dubbo-monitor/WEB-INF/classes/application.properties
	\cp -f install/dubbo-monitor.server.xml monitor/server.xml
	docker run --name monitor -d --network host --restart=always -v ${workdir}/monitor/logs:/usr/local/tomcat/logs -v ${workdir}/monitor/webapps:/usr/local/tomcat/webapps -v ${workdir}/monitor/server.xml:/usr/local/tomcat/conf/server.xml tomcat:8.5.34
else
	\cp -f install/dubbo-monitor-notlinux.properties monitor/webapps/dubbo-monitor/WEB-INF/classes/application.properties
	docker run --name monitor -d -p 8787:8080 -p 7960:6060 --restart=always -v ${workdir}/monitor/logs:/usr/local/tomcat/logs -v ${workdir}/monitor/webapps:/usr/local/tomcat/webapps tomcat:8.5.34
fi
