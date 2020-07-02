set workdir=%cd:~0,2%\var\docker
cd /d %workdir%

rem 开始安装 postgresql ...
docker stop pg
docker rm -f pg
rd /q /s postgresql
md postgresql\docker_init
md postgresql\init
md postgresql\data

copy install\postgresql\dasc-init.sh postgresql\docker_init\
copy install\postgresql\remove-init-files.sh postgresql\docker_init\
copy install\postgresql\dasc-init.sh postgresql\init\
copy install\postgresql\dasc-db.sql postgresql\init\
copy install\postgresql\dubbo-monitor.sql postgresql\init\
copy install\postgresql\dasc-tb*.sql postgresql\init\
copy install\postgresql\dasc-dev.sql postgresql\init\
rem docker-entrypoint-initdb.d中的sql和sh将会按字母顺序被执行
rem postgres容器挂载的目录如果是/var/lib/postgresql/data，那么此目录下不能有任何数据，否则会提示“PostgreSQL Database directory appears to contain a database; Skipping initialization”，不会执行/docker-entrypoint-initdb.d下的文件
rem -v %workdir%/postgresql/data:/var/lib/postgresql/data -e PGDATA=/var/lib/postgresql/data 
rem 开发环境通常使用mysql，一般不需要同时运行postgresql，因此container设置为不自动重启，需要时请加上--restart=always； 
docker run --name pg -d -p 8785:5432 -v %workdir%/postgresql/docker_init:/docker-entrypoint-initdb.d -v %workdir%/postgresql/init:/var/lib/postgresql/init -e POSTGRES_PASSWORD=Postgres.8785 -e TZ=PRC postgres:9.6.17
