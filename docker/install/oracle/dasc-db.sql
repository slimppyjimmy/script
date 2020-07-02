--创建表空间
drop tablespace @id including contents and datafiles;
create tablespace dasc_sec datafile '/u01/app/oracle/userdata/@id.dbf' size 10M autoextend on next 1M;
--创建用户
drop user @id cascade;
create user @id identified by @id default tablespace @id;
--授权
grant unlimited tablespace to @id;
grant create session to @id;
grant create table to @id;
grant create procedure to @id;
grant create sequence to @id;
grant create trigger to @id;
grant create view to @id;
grant select any table to @id;