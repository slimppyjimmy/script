# 开始安装 nodejs ...
docker stop node
docker rm -f node

#使用当前完整路径作为安装路径（docker的-v参数不能使用带有~的或相对的路径）
workdir=`pwd`
cd ${workdir}
rm -rf node
mkdir -p node/workspace
docker run --name nodejs -d -i -t -p 9022:22 --privileged=true -v ${workdir}/node/workspace:/home/myworkspace node:12.11.1