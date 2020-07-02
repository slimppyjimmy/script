rem 开始安装 mysql ...
set workdir=%cd:~0,2%\var\docker
cd /d %workdir%
docker stop mysql
docker rm -f mysql
rd /q /s mysql
md mysql\init
md mysql\data
md mysql\conf
md mysql\logs
copy install\mysql\my.cnf mysql\conf\
copy install\mysql\dasc-init.sh mysql\init\
copy install\mysql\dasc-db.sql mysql\data\
copy install\mysql\dasc-tb.sql mysql\data\
copy install\mysql\dasc-dev.sql mysql\data\
copy install\mysql\dubbo-monitor.sql mysql\data\

docker run --name mysql -d -p 8784:3306 --restart=always -v %workdir%\mysql\conf:/etc/mysql/conf.d -v %workdir%\mysql\logs:/logs -v %workdir%\mysql\data:/var/lib/mysql -v %workdir%\mysql\init:/docker-entrypoint-initdb.d -e MYSQL_ROOT_PASSWORD=Mysql.8784 mysql:5.6.44
rem 安装完毕，正在重启数据库，启动后将自动执行/docker-entrypoint-initdb.d目录下的dasc-init.sh进行初始化，请使用docker logs mysql查看初始化脚本是否执行完毕