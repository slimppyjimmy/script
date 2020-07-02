-- 由于创建表空间需要使用sys用户，但创建dasc数据库需要使用dcc_security用户，为了避免修改数据脚本（有可能时直接导出的），特使用本脚本进行组合
-- 使用system用户创建表空间ts_dasc、用户DCC_SECURITY并授权
@/u01/app/oracle/oracledata/XE/dasc-db.sql
--切换到dcc_security用户，否则表会被创建到system用户中
disconnect
connect DCC_SECURITY/dcc_security
-- 创建dubbo-monitor表
@/u01/app/oracle/oracledata/XE/dubbo-monitor.sql
-- 创建dasc表并导入数据（oracle镜像中sqlplus执行gbk编码的sql中的to_timestamp可能出问题，暂时去掉，需使用手工执行）
-- @/u01/app/oracle/oracledata/XE/dasc-tb.sql
-- 导入dasc开发环境数据（oracle镜像中sqlplus执行gbk编码的sql中的to_timestamp可能出问题，暂时去掉，需使用手工执行）
-- @/u01/app/oracle/oracledata/XE/dasc-dev.sql
-- 退出sqlplus，否则需要手工退出
exit