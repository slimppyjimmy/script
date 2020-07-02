#!/bin/bash
#创建DASC数据库、初始化数据
# psql -U postgres -f /var/lib/postgresql/init/dasc-db.sql
# psql -U dcc_security -f /var/lib/postgresql/init/dasc-tb.sql
# psql -U postgres -f /var/lib/postgresql/init/dasc-dev.sql
# psql -U postgres -f /var/lib/postgresql/init/dubbo-monitor.sql

# 使用第一个参数作为数据库标识。由于pg自动执行时使用的是sourcing，会附加其他参数，
id=$1
# 如果参数个数大于1，代表是容器自动执行的，因此执行默认的sec脚本
[ $# -gt 1 ] && id=sec
# 如果为空，则默认sec
[ -z "$id" ] && id=sec
workdir=/var/lib/postgresql/init
# 用户名、密码相同
name=dasc_${id}
echo $name
# chmod 777 ${workdir}/*
# 用name的值替换dasc-db.sql中的@id
# sed -n "s!@id!$name!gw dasc-db-tmp.sql" ${workdir}/dasc-db.sql
# 由于postgres用户对于挂载的workdir不具有写权限，因此需要输出到PGDATA目录（/var/lib/postgresql/data）下
sed "s!@id!${name}!g" ${workdir}/dasc-db.sql > /var/lib/postgresql/data/dasc-db-tmp.sql
# 创建表空间、用户
psql -U postgres -w -f /var/lib/postgresql/data/dasc-db-tmp.sql
# 创建DubboMonitor所用表。注意sql文件最后一行必须是quit，否则需要手动输入quit才能继续执行本脚本后续的语句
psql -U ${name} -w -f ${workdir}/dubbo-monitor.sql
# 初始化表及数据
tbfile=${workdir}/dasc-tb-${id}.sql
# 如果文件不存在则退出
[ ! -e "${tbfile}" ] && echo "database init file not found : ${tbfile}" && exit
psql -U ${name} -w -f ${tbfile}
# 添加开发用数据
psql -U ${name} -w -f ${workdir}/dasc-dev.sql
