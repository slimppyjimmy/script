--�����û�
drop user @id;
create user @id with password '@id';
--�������ݿ�
drop database @id;
create database @id owner @id;
--��Ȩ�û��������ݿ�
grant all privileges on database @id to @id;
