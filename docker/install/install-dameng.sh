# 开始安装达梦 ...
docker stop dameng
docker rm -f dameng

#使用当前完整路径作为安装路径（docker的-v参数不能使用带有~的或相对的路径）
workdir=`pwd`
cd ${workdir}
rm -rf dameng
mkdir -p dameng/init
mkdir -p dameng/data
cp install/dameng/dasc-init.sql dameng/init/
cp install/dameng/dasc-db.sql dameng/data/
cp install/dameng/dubbo-monitor.sql dameng/data/
cp install/dameng/dasc-tb.sql dameng/data/
cp install/dameng/dasc-dev.sql dameng/data/
docker run --name dameng -d -p 8786:5236 -v ${workdir}/dameng/data:/data -v ${workdir}/dameng/init:/docker-entrypoint-initdb.d wusuopu/dameng:dm8