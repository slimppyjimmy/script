rem 开始安装 nodejs ...
set workdir=%cd:~0,2%\var\docker
cd /d %workdir%
docker stop node
docker rm -f node
rd /q /s node
md node\workspace
docker run --name node -d -i -t -p 9022:22 --privileged=true -v %workdir%\node\workspace:/home/myworkspace node:12.11.1
npm install -g cnpm --registry=https://registry.npm.taobao.org
cnpm install -g webpack
cnpm install -g @vue/cli
cnpm install -g @vue/cli-init