-- 增加超级用户admin（密码为1）并授权。注意：仅用于开发环境
INSERT INTO DCC_USER (ID,GUID,EMAIL,ICONURL,LASTONLINEDATE,LOGINNAME,LOGINPWD,MOBILEPHONE,POSTCODE,PY,REALMGUID,REMARK,SIGNPWD,SORTNO,STATE,TELEPHONE,USERNAME,USERTYPE,ISLOCKED,LOGINFAILCOUNT,ISINSTAFF,JOBNUMBER,K_LEVEL) values (-1,'c5230ef0-337b-44ad-b4d7-9cfc47b39200',null,null,null,'admin','4ZcT49zAy8SOTKul1ms3fA==',null,null,null,null,null,'4ZcT49zAy8SOTKul1ms3fA==',1,1,null,'admin',1,false,0,false,null,'8');
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (nextval('hibernate_sequence'), 'DCF7B969-5794-417E-9F76-C5B78FA21B0D','c5230ef0-337b-44ad-b4d7-9cfc47b39200',1,'33b5f490-67cf-4d9d-afeb-ffd6c5f44da3',1);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (nextval('hibernate_sequence'), 'C9903F02-91D5-43F0-A548-48FCB2B39616','c5230ef0-337b-44ad-b4d7-9cfc47b39200',1,'e9005a27-d752-40fc-920a-c67d1512f370',1);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (nextval('hibernate_sequence'), 'FA7140AA-5F02-40D5-B5A7-344AA5A32837','c5230ef0-337b-44ad-b4d7-9cfc47b39200',1,'cc735573-de13-4ef4-a4c3-49f7e989c5c8',1);
INSERT INTO DCC_REALM_MANAGER (ID, GUID, REALMGUID, USERGUID) VALUES (nextval('hibernate_sequence'), 'BF0A01CF-C3F6-4F60-BD35-CA0622B12978', 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 'c5230ef0-337b-44ad-b4d7-9cfc47b39200');
INSERT INTO DCC_APP_MANAGER (ID, GUID, APPGUID, USERGUID) VALUES (nextval('hibernate_sequence'), 'BA2B7F4A-244F-4E79-923F-0D5D62EA773B', '43972DD7-CF57-46AF-9D60-CED094C9E738', 'c5230ef0-337b-44ad-b4d7-9cfc47b39200');
-- 设置密码永不过期
UPDATE DCC_CONFIG_VALUE SET K_VALUE=0 WHERE DEFINITIONGUID='980376e5-6312-11e7-8549-00ff14e091ec';
-- 修改admin开头的所有用户的登录密码为1
UPDATE DCC_USER SET LOGINPWD='4ZcT49zAy8SOTKul1ms3fA==' WHERE LOGINNAME LIKE 'admin%';