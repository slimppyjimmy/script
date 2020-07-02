set workdir=%cd:~0,2%\var\docker
cd /d %workdir%

rem 开始安装 oracle ...
docker stop oracle
docker rm -f oracle
rd /q /s oracle
md oracle\init
md oracle\userdata

copy install\oracle\dasc-init.sql oracle\init\
copy install\oracle\remove-init-files.sh oracle\init\
copy install\oracle\dasc-db.sql oracle\userdata\
copy install\oracle\dubbo-monitor.sql oracle\userdata\
copy install\oracle\dasc-tb.sql oracle\userdata\
copy install\oracle\dasc-dev.sql oracle\userdata\
rem docker-entrypoint-initdb.d中的sql和sh将会按字母顺序被执行
rem -e NLS_LANG="SIMPLIFIED CHINESE_CHINA.ZHS16GBK" 
rem 开发环境通常使用mysql，一般不需要同时运行oracle，因此container设置为不自动重启，需要时请加上--restart=always 
docker run --name oracle -d -p 7972:8080 -p 8783:1521 -v %workdir%\oracle\userdata:/u01/app/oracle/oracledata/XE -v %workdir%\oracle\init:/docker-entrypoint-initdb.d -e ORACLE_DISABLE_ASYNCH_IO=true -e NLS_LANG="SIMPLIFIED CHINESE_CHINA.ZHS16GBK" yunql/oracle-xe-11gr2-zh:1.0.0