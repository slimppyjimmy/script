# 开始安装 mysql ...
docker stop mysql
docker rm -f mysql

#使用当前完整路径作为安装路径（docker的-v参数不能使用带有~的或相对的路径）
workdir=`pwd`
cd ${workdir}
rm -rf mysql
mkdir -p mysql/init
mkdir -p mysql/data
mkdir -p mysql/conf
mkdir -p mysql/logs
cp install/mysql/my.cnf mysql/conf/
cp install/mysql/dasc-init.sh mysql/init/
cp install/mysql/dasc-db.sql mysql/data/
cp install/mysql/dasc-tb.sql mysql/data/
cp install/mysql/dasc-dev.sql mysql/data/
cp install/mysql/dubbo-monitor.sql mysql/data/

docker run --name mysql -d -p 8784:3306 --restart=always -v ${workdir}/mysql/conf:/etc/mysql/conf.d -v ${workdir}/mysql/logs:/logs -v ${workdir}/mysql/data:/var/lib/mysql -v ${workdir}/mysql/init:/docker-entrypoint-initdb.d -e MYSQL_ROOT_PASSWORD=Mysql.8784 mysql:5.6.45
# 安装完毕，正在重启数据库，启动后将自动执行/docker-entrypoint-initdb.d目录下的dasc-init.sh进行初始化，请使用docker logs mysql查看初始化脚本是否执行完毕