drop table DUBBO_INVOKE;
create table DUBBO_INVOKE
(
	ID varchar(255) not null
		primary key,
	INVOKE_DATE timestamp not null,
	SERVICE varchar(255) default NULL,
	METHOD varchar(255) default NULL,
	CONSUMER varchar(255) default NULL,
	PROVIDER varchar(255) default NULL,
	TYPE varchar(255) default '',
	INVOKE_TIME bigint default NULL,
	SUCCESS integer default NULL,
	FAILURE integer default NULL,
	ELAPSED integer default NULL,
	CONCURRENT integer default NULL,
	MAX_ELAPSED integer default NULL,
	MAX_CONCURRENT integer default NULL
);
