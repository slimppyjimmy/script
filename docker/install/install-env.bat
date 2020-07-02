rem ��ȷ�����ű����ڵ�Ŀ¼Ϊ\var\docker\install��\var\docker�г�installĿ¼���Ŀ¼�����ܻᱻɾ����
rem Ĭ�����ݿ⽫��װmysql�������Ҫ��װoracle����ִ�б��ű�ʱЯ������������install-env oracle
pause ���������ʼ��װ...

set workdir=%cd:~0,2%\var\docker
cd /d %workdir%

rem ��ʼ��װ nginx ...
docker stop nginx
docker rm -f nginx ...
rd /q /s nginx
md nginx\logs
md nginx\www
rem ע�⣺����host����ֻ����linux��ʹ�ã�������mac��windows��ʹ�ã������linux������ʹ��"--network host"��nginx.conf��proxy_passʹ��localhost����mac��windows��ʹ��"-p 8775:8775"��nginx.conf��proxy_passʹ��host.docker.internal
copy install\nginx.notlinux.conf nginx\nginx.conf
docker run --name nginx -d -p 8777:8777 -p 8778:8778 --restart=always -v %workdir%\nginx\nginx.conf:/etc/nginx/nginx.conf -v %workdir%\nginx\logs:/var/log/nginx -v %workdir%\nginx\www:/usr/share/nginx/html nginx:1.17.1
rem

rem ��ʼ��װ zookeeper ...
docker stop zookeeper
docker rm -f zookeeper
docker run --name zookeeper -d -p 8780:2181 --restart=always zookeeper:3.5.5

rem ��ʼ��װ redis ...
docker stop redis
docker rm -f redis
rd /q /s redis
md redis\data
copy install\redis.conf redis

docker run --name redis -d -p 8781:6379 --restart=always -v %workdir%\redis\redis.conf:/etc/redis/redis.conf -v %workdir%\redis\data:/data  redis:5.0.5 redis-server /etc/redis/redis.conf
rem

rem ��ʼ��װ openldap ...
docker stop ldap
docker rm -f ldap
rd /q /s openldap
md openldap\data
md openldap\conf

docker run --name ldap -d -p 8782:389 -p 7936:636 --restart=always -v %workdir%\openldap\data:/var/lib/ldap -v %workdir%\openldap\conf:/etc/ldap/slapd.d --env LDAP_ADMIN_PASSWORD=Ldap.8782 --env LDAP_ORGANISATION="Easy Means" --env LDAP_DOMAIN="easymeans.cn" osixia/openldap:1.2.4
rem ע�⣺������ȴ������ܳ��ִ���Error: No such container openldap
choice /C YNC /CS /D Y /N  /M "ldap�����У��ȴ�30�� ..." /T 30
rem
rem ע�⣺��һ�в�������������ǰִ�У��������������޷�������logs����ʾ����Error: the database directory (\var\lib\ldap) is empty but not the config directory (\etc\ldap\slapd.d)
copy install\ldap.init.ldif openldap\conf
docker exec -it ldap ldapadd -x -D "cn=admin,dc=easymeans,dc=cn"  -w Ldap.8782 -f /etc/ldap/slapd.d/ldap.init.ldif
rem

rem call install\install-monitor.bat

if "%1"=="oracle" (call install\install-oracle.bat) else call install\install-mysql.bat

rem ��ʼ��װ portainer ...
rem rd /q /s portainer
rem md portainer\data
rem docker rm -f portainer
rem docker run --name portainer -d -p 8788:9000 --restart=always -v //./pipe/docker_engine:/var/run/docker.sock -v %workdir%\portainer\data:/data portainer/portainer:1.21.0
rem pause �����Ϸ���http:\\localhost:8788������admin�û�������5����֮��Ӧ�ý����Զ�ֹͣ
