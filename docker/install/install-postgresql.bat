set workdir=%cd:~0,2%\var\docker
cd /d %workdir%

rem ��ʼ��װ postgresql ...
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
rem docker-entrypoint-initdb.d�е�sql��sh���ᰴ��ĸ˳��ִ��
rem postgres�������ص�Ŀ¼�����/var/lib/postgresql/data����ô��Ŀ¼�²������κ����ݣ��������ʾ��PostgreSQL Database directory appears to contain a database; Skipping initialization��������ִ��/docker-entrypoint-initdb.d�µ��ļ�
rem -v %workdir%/postgresql/data:/var/lib/postgresql/data -e PGDATA=/var/lib/postgresql/data 
rem ��������ͨ��ʹ��mysql��һ�㲻��Ҫͬʱ����postgresql�����container����Ϊ���Զ���������Ҫʱ�����--restart=always�� 
docker run --name pg -d -p 8785:5432 -v %workdir%/postgresql/docker_init:/docker-entrypoint-initdb.d -v %workdir%/postgresql/init:/var/lib/postgresql/init -e POSTGRES_PASSWORD=Postgres.8785 -e TZ=PRC postgres:9.6.17
