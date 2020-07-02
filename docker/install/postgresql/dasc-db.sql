--创建用户
drop user @id;
create user @id with password '@id';
--创建数据库
drop database @id;
create database @id owner @id;
--授权用户访问数据库
grant all privileges on database @id to @id;
