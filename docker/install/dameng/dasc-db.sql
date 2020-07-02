select userenv('language') from dual;
--将数据库编码设置为gbk，否则数据初始化部分语句将会失败
alter system enable restricted session;
alter database character set internal_use ZHS16GBK;
shutdown immediate;
startup;
--设置密码永不过期
alter profile default limit password_life_time unlimited;
--创建表空间
drop tablespace ts_dasc including contents and datafiles;
create tablespace ts_dasc datafile '/u01/app/oracle/oracledata/XE/ts_dasc.dbf' size 10M autoextend on next 1M;
--创建用户
drop user DCC_SECURITY cascade;
create user DCC_SECURITY identified by dcc_security default tablespace ts_dasc;
--授权
grant unlimited tablespace to DCC_SECURITY;
grant create session to DCC_SECURITY;
grant create table to DCC_SECURITY;
grant create procedure to DCC_SECURITY;
grant create sequence to DCC_SECURITY;
grant create trigger to DCC_SECURITY;
grant create view to DCC_SECURITY;
grant select any table to DCC_SECURITY;