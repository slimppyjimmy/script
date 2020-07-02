# 使用第一个参数作为数据库标识
id=$1
# 如果为空，则默认sec
[ -z "$id" ] && id=dasc_sec
workdir=/u01/app/oracle/userdata
# 用name的值替换dasc-db.sql中的@id
sed -n "s/@id/${id}/gw dasc-db-tmp.sql" ${workdir}/dasc-db.sql
# 创建表空间、用户。注意sql文件最后一行必须是quit，否则需要手动输入quit才能继续执行本脚本后续的语句
sqlplus sys/oracle as sysdba @dasc-db-tmp.sql
# 创建DubboMonitor所用表。注意sql文件最后一行必须是quit，否则需要手动输入quit才能继续执行本脚本后续的语句
sqlplus ${id}/${id} @${workdir}/dubbo-monitor.sql
# 初始化表及数据
tbfile=${workdir}/${id}.sql
# 如果文件不存在则退出
[ ! -e "${tbfile}" ] && echo "database init file not found : ${tbfile}" && exit
sqlplus ${id}/${id} @${tbfile}
# 添加开发用数据
sqlplus ${id}/${id} @${workdir}/dasc-dev.sql
