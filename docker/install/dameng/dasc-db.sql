select userenv('language') from dual;
--�����ݿ��������Ϊgbk���������ݳ�ʼ��������佫��ʧ��
alter system enable restricted session;
alter database character set internal_use ZHS16GBK;
shutdown immediate;
startup;
--����������������
alter profile default limit password_life_time unlimited;
--������ռ�
drop tablespace ts_dasc including contents and datafiles;
create tablespace ts_dasc datafile '/u01/app/oracle/oracledata/XE/ts_dasc.dbf' size 10M autoextend on next 1M;
--�����û�
drop user DCC_SECURITY cascade;
create user DCC_SECURITY identified by dcc_security default tablespace ts_dasc;
--��Ȩ
grant unlimited tablespace to DCC_SECURITY;
grant create session to DCC_SECURITY;
grant create table to DCC_SECURITY;
grant create procedure to DCC_SECURITY;
grant create sequence to DCC_SECURITY;
grant create trigger to DCC_SECURITY;
grant create view to DCC_SECURITY;
grant select any table to DCC_SECURITY;