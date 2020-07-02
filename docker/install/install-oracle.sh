# 开始安装 oracle ...
docker stop oracle
docker rm -f oracle

#使用当前完整路径作为安装路径（docker的-v参数不能使用带有~的或相对的路径）
workdir=`pwd`
cd ${workdir}
rm -rf oracle
mkdir -p oracle/init
mkdir -p oracle/userdata
cp install/oracle/dasc-init.sql oracle/init/
cp install/oracle/remove-init-files.sh oracle/init/
cp install/oracle/dasc-db.sql oracle/userdata/
cp install/oracle/dubbo-monitor.sql oracle/userdata/
# cp install/oracle/dasc-tb.sql oracle/userdata/
# cp install/oracle/dasc-dev.sql oracle/userdata/
# docker-entrypoint-initdb.d中的sql和sh将会按字母顺序被执行
# -e NLS_LANG="SIMPLIFIED CHINESE_CHINA.ZHS16GBK" 
# 开发环境通常使用mysql，一般不需要同时运行oracle，因此container设置为不自动重启，需要时请加上--restart=always 
docker run --name oracle -d -p 7972:8080 -p 8783:1521 -v ${workdir}/oracle/userdata:/u01/app/oracle/oracledata/XE -v ${workdir}/oracle/init:/docker-entrypoint-initdb.d -e ORACLE_DISABLE_ASYNCH_IO=true yunql/oracle-xe-11gr2-zh:1.0.0
# wnameless/oracle-xe-11g-r2
echo 
read -p '在oracle镜像中sqlplus执行gbk编码的sql时，部分含有to_timestamp的语句会有问题，请自行在客户端使用gbk编码执行dasc-tb.sql（即DASC_?.?.?.RELEASE_INIT_ORACLE.sql）和dasc-dev.sql（开发环境数据）。按任意键继续' -n 1
