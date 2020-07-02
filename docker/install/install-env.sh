# 请确保本脚本所在的目录为\var\docker\install，\var\docker中除install目录外的目录将可能会被删除；
# 默认数据库将安装mysql，如果需要安装oracle，请执行本脚本时携带参数，即：install-env oracle
read -p '按任意键开始安装...' -n 1

SYSTEM=`uname -s`
#可自定义此路径，或删除以下两行使用当前路径
workdir=/var/docker
cd ${workdir}
#使用当前完整路径作为安装路径（docker的-v参数不能使用带有~的或相对的路径）
workdir=`pwd`
# 开始安装 nginx ...
docker rm -f nginx ...
rm -rf nginx
mkdir -p nginx/logs
mkdir -p nginx/www
#注意：由于host网络只能在linux下使用，不能在mac和windows下使用，因此在linux主机中使用"--network host"、nginx.conf中proxy_pass使用localhost，在mac和windows中使用"-p 8775:8775"、nginx.conf中proxy_pass使用host.docker.internal
if [ "$SYSTEM" == "Linux" ]
then 
	cp install/nginx.linux.conf nginx/nginx.conf
	docker run --name nginx -d --network host --restart=always -v ${workdir}/nginx/nginx.conf:/etc/nginx/nginx.conf -v ${workdir}/nginx/logs:/var/log/nginx -v ${workdir}/nginx/www:/usr/share/nginx/html nginx:1.17.1
else
	cp install/nginx.notlinux.conf nginx/nginx.conf
	docker run --name nginx -d -p 8777:8777 -p 8778:8778 --restart=always -v ${workdir}/nginx/nginx.conf:/etc/nginx/nginx.conf -v ${workdir}/nginx/logs:/var/log/nginx -v ${workdir}/nginx/www:/usr/share/nginx/html nginx:1.17.1
fi

# 开始安装 zookeeper ...
docker rm -f zookeeper
docker run --name zookeeper -d -p 8780:2181 --restart=always zookeeper:3.5.5

# 开始安装 redis ...
docker rm -f redis
rm -rf redis
mkdir -p redis/data
cp install/redis.conf redis

docker run --name redis -d -p 8781:6379 --restart=always -v ${workdir}/redis/redis.conf:/etc/redis/redis.conf -v ${workdir}/redis/data:/data  redis:5.0.5 redis-server /etc/redis/redis.conf

# 开始安装 openldap ...
rm -rf openldap
mkdir -p openldap/data
mkdir -p openldap/conf

docker rm -f ldap
docker run --name ldap -d -p 8782:389 -p 7936:636 --restart=always -v ${workdir}/openldap/data:/var/lib/ldap -v ${workdir}/openldap/conf:/etc/ldap/slapd.d --env LDAP_ADMIN_PASSWORD=Ldap.8782 --env LDAP_ORGANISATION="Easy Means" --env LDAP_DOMAIN="easymeans.cn" osixia/openldap:1.2.4
read -p 'ldap启动中，等待30秒 (如果不等待，可能出错误：Error: No such container openldap)...' -t 30
# 注意：下一行不能在容器启动前执行，否则容器将会无法启动，logs中显示错误：Error: the database directory (/var/lib/ldap) is empty but not the config directory (/etc/ldap/slapd.d)
cp install/ldap.init.ldif openldap/conf
docker exec -it ldap ldapadd -x -D "cn=admin,dc=easymeans,dc=cn"  -w Ldap.8782 -f /etc/ldap/slapd.d/ldap.init.ldif

sh install/install-monitor.sh

if [ "$1"x = "oracle"x ]
then
	sh install/install-oracle.sh
else
	sh install/install-mysql.sh
fi

# 开始安装 portainer ...
# docker rm -f portainer
# rm -rf portainer
# mkdir -p portainer/data
# docker run --name portainer -d -p 8788:9000 --restart=always -v  /var/run/docker.sock:/var/run/docker.sock -v ${workdir}/portainer/data:/data portainer/portainer:1.21.0
# 请马上访问http://localhost:8788，创建admin用户，否则5分钟之后应用将会自动停止且无法启动
