echo 创建 dasc_test 数据库 ...
mysql -uroot -pMysql.8784</var/lib/mysql/dasc_test.db.sql
echo 导入 dasc_test 数据表 ...
mysql -uroot -pMysql.8784 -Ddasc_test</var/lib/mysql/DASC_2.8.1.RELEASE_INIT_MYSQL.sql
echo 创建 dubbo-monitor 数据库 ...
mysql -uroot -pMysql.8784 -Ddasc_test</var/lib/mysql/dubbo-monitor.sql
echo 导入 dasc_test 开发环境配置 ...
mysql -uroot -pMysql.8784 -Ddasc_test</var/lib/mysql/dasc.dev.sql