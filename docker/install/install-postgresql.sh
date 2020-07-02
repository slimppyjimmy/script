# 开始安装 postgresql ...
docker stop pg
docker rm -f pg

#使用当前完整路径作为安装路径（docker的-v参数不能使用带有~的或相对的路径）
workdir=`pwd`
cd ${workdir}
rm -rf postgresql
mkdir -p postgresql/docker_init
mkdir -p postgresql/init
mkdir -p postgresql/data
cp install/postgresql/dasc-init.sh postgresql/docker_init/
cp install/postgresql/remove-init-files.sh postgresql/docker_init/
cp install/postgresql/dasc-init.sh postgresql/init/
cp install/postgresql/dasc-db.sql postgresql/init/
cp install/postgresql/dubbo-monitor.sql postgresql/init/
cp install/postgresql/dasc-tb*.sql postgresql/init/
cp install/postgresql/dasc-dev.sql postgresql/init/
# docker-entrypoint-initdb.d中的sql和sh将会按字母顺序被执行
# 开发环境通常使用mysql，一般不需要同时运行postgres，因此container设置为不自动重启，需要时请加上--restart=always 
# postgres容器挂载的目录如果是/var/lib/postgresql/data，那么此目录下不能有任何数据，否则会提示“PostgreSQL Database directory appears to contain a database; Skipping initialization”，不会执行/docker-entrypoint-initdb.d下的文件
docker run --name pg -d --privileged=true -p 8785:5432 -v ${workdir}/postgresql/docker_init:/docker-entrypoint-initdb.d -v ${workdir}/postgresql/init:/var/lib/postgresql/init -v ${workdir}/postgresql/data:/var/lib/postgresql/data -e PGDATA=/var/lib/postgresql/data -e POSTGRES_PASSWORD=Postgres.8785 -e TZ=PRC postgres:9.6.17
