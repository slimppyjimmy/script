create or replace function dasc_guid()
    returns varchar as
$$
declare
    v_seed_value varchar (32);
begin
    select md5(
                               inet_client_addr()::varchar ||
                               timeofday() ||
                               inet_server_addr()::varchar ||
                               to_hex(inet_client_port())
               )
    into v_seed_value;

    return upper(
                                            substr(v_seed_value,1,8) || '-' ||
                                            substr(v_seed_value,9,4) || '-' ||
                                            substr(v_seed_value,13,4) || '-' ||
                                            substr(v_seed_value,17,4) || '-' ||
                                            substr(v_seed_value,21,12)
        );
end;
$$ language plpgsql;

drop table if exists dcc_ace;
drop table if exists dcc_app;
drop table if exists dcc_app_health_config;
drop table if exists dcc_app_manager;
drop table if exists dcc_audit_event;
drop table if exists dcc_audit_log;
drop table if exists dcc_audit_statistics;
drop table if exists dcc_bdf_login_user;
drop table if exists dcc_config_definition;
drop table if exists dcc_config_definition_option;
drop table if exists dcc_config_value;
drop table if exists dcc_data_notification;
drop table if exists dcc_dictionary;
drop table if exists dcc_dictionary_type;
drop table if exists dcc_extended_info;
drop table if exists dcc_field_validate_definition;
drop table if exists dcc_function;
drop table if exists dcc_health_device;
drop table if exists dcc_health_device_status;
drop table if exists dcc_health_server;
drop table if exists dcc_job;
drop table if exists dcc_login_user;
drop table if exists dcc_notice;
drop table if exists dcc_notice_user;
drop table if exists dcc_operation;
drop table if exists dcc_org;
drop table if exists dcc_org_role;
drop table if exists dcc_org_user;
drop table if exists dcc_pwd_history;
drop table if exists dcc_realm;
drop table if exists dcc_realm_manager;
drop table if exists dcc_realm_org;
drop table if exists dcc_role;
drop table if exists dcc_role_member;
drop table if exists dcc_sql_script_exe_log;
drop table if exists dcc_station;
drop table if exists dcc_sync_app;
drop table if exists dcc_sync_task;
drop table if exists dcc_sync_task_log;
drop table if exists dcc_sync_task_log_detail;
drop table if exists dcc_user;
drop table if exists dcc_user_agent;
drop table if exists dcc_user_shortcut;
drop sequence if exists hibernate_sequence;

create sequence hibernate_sequence minvalue 1 increment by 1 start with 1840 cache 20;

drop table if exists qrtz_fired_triggers;
drop table if exists qrtz_paused_trigger_grps;
drop table if exists qrtz_scheduler_state;
drop table if exists qrtz_locks;
drop table if exists qrtz_simple_triggers;
drop table if exists qrtz_simprop_triggers;
drop table if exists qrtz_cron_triggers;
drop table if exists qrtz_blob_triggers;
drop table if exists qrtz_triggers;
drop table if exists qrtz_job_details;
drop table if exists qrtz_calendars;

create table qrtz_job_details
(
    sched_name varchar(120) not null,
    job_name varchar(190) not null,
    job_group varchar(190) not null,
    description varchar(250) null,
    job_class_name varchar(250) not null,
    is_durable boolean not null,
    is_nonconcurrent boolean not null,
    is_update_data boolean not null,
    requests_recovery boolean not null,
    job_data bytea null
);
alter table qrtz_job_details add primary key(sched_name, job_name, job_group);
create index idx_qrtz_j_req_recovery on qrtz_job_details(sched_name, requests_recovery);
create index idx_qrtz_j_grp on qrtz_job_details(sched_name, job_group);

create table qrtz_triggers
(
    sched_name varchar(120) not null,
    trigger_name varchar(190) not null,
    trigger_group varchar(190) not null,
    job_name varchar(190) not null,
    job_group varchar(190) not null,
    description varchar(250) null,
    next_fire_time bigint null,
    prev_fire_time bigint null,
    priority integer null,
    trigger_state varchar(16) not null,
    trigger_type varchar(8) not null,
    start_time bigint not null,
    end_time bigint null,
    calendar_name varchar(190) null,
    misfire_instr smallint null,
    job_data bytea null
);
alter table qrtz_triggers add primary key(sched_name, trigger_name, trigger_group);
create index idx_qrtz_t_j on qrtz_triggers(sched_name, job_name, job_group);
create index idx_qrtz_t_jg on qrtz_triggers(sched_name, job_group);
create index idx_qrtz_t_c on qrtz_triggers(sched_name, calendar_name);
create index idx_qrtz_t_g on qrtz_triggers(sched_name, trigger_group);
create index idx_qrtz_t_state on qrtz_triggers(sched_name, trigger_state);
create index idx_qrtz_t_n_state on qrtz_triggers(sched_name, trigger_name, trigger_group, trigger_state);
create index idx_qrtz_t_n_g_state on qrtz_triggers(sched_name, trigger_group, trigger_state);
create index idx_qrtz_t_next_fire_time on qrtz_triggers(sched_name, next_fire_time);
create index idx_qrtz_t_nft_st on qrtz_triggers(sched_name, trigger_state, next_fire_time);
create index idx_qrtz_t_nft_misfire on qrtz_triggers(sched_name, misfire_instr, next_fire_time);
create index idx_qrtz_t_nft_st_misfire on qrtz_triggers(sched_name, misfire_instr, next_fire_time, trigger_state);
create index idx_qrtz_t_nft_st_misfire_grp on qrtz_triggers(sched_name, misfire_instr, next_fire_time, trigger_group, trigger_state);

create table qrtz_simple_triggers
(
    sched_name varchar(120) not null,
    trigger_name varchar(190) not null,
    trigger_group varchar(190) not null,
    repeat_count bigint not null,
    repeat_interval bigint not null,
    times_triggered bigint not null
);
alter table qrtz_simple_triggers add primary key(sched_name, trigger_name, trigger_group);

create table qrtz_cron_triggers
(
    sched_name varchar(120) not null,
    trigger_name varchar(190) not null,
    trigger_group varchar(190) not null,
    cron_expression varchar(120) not null,
    time_zone_id varchar(80)
);
alter table qrtz_cron_triggers add primary key(sched_name, trigger_name, trigger_group);

create table qrtz_simprop_triggers
(
    sched_name varchar(120) not null,
    trigger_name varchar(190) not null,
    trigger_group varchar(190) not null,
    str_prop_1 varchar(512) null,
    str_prop_2 varchar(512) null,
    str_prop_3 varchar(512) null,
    int_prop_1 int null,
    int_prop_2 int null,
    long_prop_1 bigint null,
    long_prop_2 bigint null,
    dec_prop_1 numeric(13, 4) null,
    dec_prop_2 numeric(13, 4) null,
    bool_prop_1 boolean null,
    bool_prop_2 boolean null
);
alter table qrtz_simprop_triggers add primary key(sched_name, trigger_name, trigger_group);

create table qrtz_blob_triggers
(
    sched_name varchar(120) not null,
    trigger_name varchar(190) not null,
    trigger_group varchar(190) not null,
    blob_data bytea null
);
alter table qrtz_blob_triggers add primary key(sched_name, trigger_name, trigger_group);

create table qrtz_calendars
(
    sched_name varchar(120) not null,
    calendar_name varchar(190) not null,
    calendar bytea not null
);
alter table qrtz_calendars add primary key(sched_name, calendar_name);

create table qrtz_paused_trigger_grps
(
    sched_name varchar(120) not null,
    trigger_group varchar(190) not null
);
alter table qrtz_paused_trigger_grps add primary key(sched_name, trigger_group);

create table qrtz_fired_triggers
(
    sched_name varchar(120) not null,
    entry_id varchar(95) not null,
    trigger_name varchar(190) not null,
    trigger_group varchar(190) not null,
    instance_name varchar(200) not null,
    fired_time bigint not null,
    sched_time bigint not null,
    priority integer not null,
    state varchar(16) not null,
    job_name varchar(190) null,
    job_group varchar(190) null,
    is_nonconcurrent boolean null,
    requests_recovery boolean null
);
alter table qrtz_fired_triggers add primary key(sched_name, entry_id);
create index idx_qrtz_ft_trig_inst_name on qrtz_fired_triggers(sched_name, instance_name);
create index idx_qrtz_ft_inst_job_req_rcvry on qrtz_fired_triggers(sched_name, instance_name, requests_recovery);
create index idx_qrtz_ft_j_g on qrtz_fired_triggers(sched_name, job_name, job_group);
create index idx_qrtz_ft_jg on qrtz_fired_triggers(sched_name, job_group);
create index idx_qrtz_ft_t_g on qrtz_fired_triggers(sched_name, trigger_name, trigger_group);
create index idx_qrtz_ft_tg on qrtz_fired_triggers(sched_name, trigger_group);

create table qrtz_scheduler_state
(
    sched_name varchar(120) not null,
    instance_name varchar(200) not null,
    last_checkin_time bigint not null,
    checkin_interval bigint not null
);
alter table qrtz_scheduler_state add primary key(sched_name, instance_name);

create table qrtz_locks
(
    sched_name varchar(120) not null,
    lock_name varchar(40) not null
);
alter table qrtz_locks add primary key(sched_name, lock_name);

insert into qrtz_job_details (sched_name, job_name, job_group, description, job_class_name, is_durable,
                              is_nonconcurrent, is_update_data, requests_recovery, job_data)
values ('DASCSchedulerFactoryBean', 'd3391c41-0886-40be-b944-941723c5d601', 'DEFAULT', null,
        'com.dist.schedule.InvokeJobDetail', '0', '1', '0', '0', null);
insert into qrtz_job_details (sched_name, job_name, job_group, description, job_class_name, is_durable,
                              is_nonconcurrent, is_update_data, requests_recovery, job_data)
values ('DASCSchedulerFactoryBean', '079f6ae6-c1a8-4840-b418-17000574c6e8', 'DEFAULT', null,
        'com.dist.schedule.InvokeJobDetail', '0', '1', '0', '0', null);
insert into qrtz_job_details (sched_name, job_name, job_group, description, job_class_name, is_durable,
                              is_nonconcurrent, is_update_data, requests_recovery, job_data)
values ('DASCSchedulerFactoryBean', '1d7b6dfd-cc34-4799-b2b5-6b72fe752151', 'DEFAULT', null,
        'com.dist.schedule.InvokeJobDetail', '0', '1', '0', '0', null);

insert into qrtz_triggers (sched_name, trigger_name, trigger_group, job_name, job_group, description, next_fire_time,
                           prev_fire_time, priority, trigger_state, trigger_type, start_time, end_time, calendar_name,
                           misfire_instr, job_data)
values ('DASCSchedulerFactoryBean', '3dbd0158-d55e-4f16-8541-ce78b47e5152', 'DEFAULT',
        'd3391c41-0886-40be-b944-941723c5d601', 'DEFAULT', null, 1522864800000, -1, 5, 'WAITING', 'CRON', 1522825883000,
        0, null, 0, null);
insert into qrtz_triggers (sched_name, trigger_name, trigger_group, job_name, job_group, description, next_fire_time,
                           prev_fire_time, priority, trigger_state, trigger_type, start_time, end_time, calendar_name,
                           misfire_instr, job_data)
values ('DASCSchedulerFactoryBean', 'fef26ccd-704b-417d-b5c9-127d512619f6', 'DEFAULT',
        '079f6ae6-c1a8-4840-b418-17000574c6e8', 'DEFAULT', null, 1522872000000, -1, 5, 'WAITING', 'CRON', 1522825905000,
        0, null, 0, null);
insert into qrtz_triggers (sched_name, trigger_name, trigger_group, job_name, job_group, description, next_fire_time,
                           prev_fire_time, priority, trigger_state, trigger_type, start_time, end_time, calendar_name,
                           misfire_instr, job_data)
values ('DASCSchedulerFactoryBean', '81232955-fb6e-4b08-b759-cd867412ac40', 'DEFAULT',
        '1d7b6dfd-cc34-4799-b2b5-6b72fe752151', 'DEFAULT', null, 1522826400000, 1522826100000, 5, 'WAITING', 'CRON',
        1522825928000, 0, null, 0, null);

insert into qrtz_cron_triggers (sched_name, trigger_name, trigger_group, cron_expression, time_zone_id)
values ('DASCSchedulerFactoryBean', '3dbd0158-d55e-4f16-8541-ce78b47e5152', 'DEFAULT', '0 0 2 * * ?', 'Asia/Shanghai');
insert into qrtz_cron_triggers (sched_name, trigger_name, trigger_group, cron_expression, time_zone_id)
values ('DASCSchedulerFactoryBean', 'fef26ccd-704b-417d-b5c9-127d512619f6', 'DEFAULT', '0 0 4 * * ?', 'Asia/Shanghai');
insert into qrtz_cron_triggers (sched_name, trigger_name, trigger_group, cron_expression, time_zone_id)
values ('DASCSchedulerFactoryBean', '81232955-fb6e-4b08-b759-cd867412ac40', 'DEFAULT', '0 0/5 * * * ?',
        'Asia/Shanghai');

insert into qrtz_locks (sched_name, lock_name)
values ('DASCSchedulerFactoryBean', 'STATE_ACCESS');
insert into qrtz_locks (sched_name, lock_name)
values ('DASCSchedulerFactoryBean', 'TRIGGER_ACCESS');
insert into qrtz_locks (sched_name, lock_name)
values ('schedulerFactoryBean', 'STATE_ACCESS');
insert into qrtz_locks (sched_name, lock_name)
values ('schedulerFactoryBean', 'TRIGGER_ACCESS');

create table DCC_ACE
(
    ID              integer        not null
        primary key,
    GUID            varchar(38) not null
        constraint UK_97W043GTKDEXDWI22CWK4YSF4
            unique,
    AGENTENDTIME    TIMESTAMP(6),
    AGENTGUID       varchar(38),
    AGENTSTARTTIME  TIMESTAMP(6),
    MANAGEREALMGUID varchar(38),
    OPERATIONMASKS  bigint,
    PERMISSIONTYPE  integer,
    PRIORITY        integer,
    RESOURCEGUID    varchar(38),
    RESOURCETYPE    integer,
    SUBJECTGUID     varchar(38),
    SUBJECTTYPE     integer
);

INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1250, '93c63eeb-5f0b-4106-834b-9b6de7ea4f69', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'EC4258B6-96B1-4FEA-83FE-4282752461FA', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1340, '355B52A7-6C63-4705-8341-9092F98748E9', null, null, null, null, null, null, null, '4d82a534-a18c-467a-93de-ab02a6150ee5', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1360, '5D398667-9CF9-4810-93A6-B41436753636', null, null, null, null, null, null, null, '9464daaf-9415-4b5a-bdb3-2614bf2d88bb', 1, 'C1752055-CA52-48D3-B858-9639BDE13B20', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1361, '7B9288F0-9270-419B-86D2-9B6648CD4032', null, null, null, null, null, null, null, 'AB871E14-652C-469B-BA16-B586B09188C6', 1, 'C1752055-CA52-48D3-B858-9639BDE13B20', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1362, 'E021A134-6D2E-414B-8FC6-A0C7299664E5', null, null, null, null, null, null, null, '3ec3c941-e2fb-4acd-b03a-bb3887635a7e', 1, 'C1752055-CA52-48D3-B858-9639BDE13B20', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1367, '69D0CBA0-2159-4393-AA30-94E7376B48A5', null, null, null, null, null, null, null, '1727C460-021B-4697-AD16-8D6C9F65B1E0', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1561, '50CE2630-2E38-4686-978F-A79CFD6964FB', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '260092A8-282C-4B91-AAC8-BFF5CA953EF7', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1575, 'E638C415-B253-45B8-AA86-993E95AE398A', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'F45A1C76-8BEB-4F33-A86E-A0C1B6A001F0', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1635, '0BFEAAFB-4A75-4AEE-8F53-A3611989FEA6', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '75B837C7-FB40-79CC-E053-E053B80E1FAC', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1638, '4dade5b2-d354-41fc-ab92-274acdd98d09', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'e2e65ed8-72dd-4b20-8209-5647d0686d37', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1368, '73D1A640-DC5E-496C-8962-9E250DB272CE', null, null, null, null, null, null, null, '26DE3567-85FD-4E49-A9F4-8FE42B92810D', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1369, 'A349A3C6-99C5-48BA-AC75-BCDFE4A17286', null, null, null, null, null, null, null, '4CAC47A7-13ED-417C-8C6B-873513F99A7E', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1375, '9bdb1511-dd57-40b5-840b-76693b3b8af9', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '2530d0b6-a8f2-4923-9fd6-87482119de41', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1377, '2223e3e8-a5b2-4a96-9b93-6fd81a9778bb', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'fa4f664f-8892-48a6-adfb-a81217271d57', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1282, 'A9295523-0FC3-47DE-ABAE-9DBE0921C722', null, null, null, null, null, null, null, 'ffbc5b6f-2310-4217-b9c9-90d57021004b', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1283, 'F34F6BD0-E52D-494B-A3AA-B0F33D052718', null, null, null, null, null, null, null, '92ddf0be-17a8-47d1-9234-f1446fe2f7c8', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1284, 'BA2F8D0C-954D-437B-A1AB-AFB62E64BA83', null, null, null, null, null, null, null, 'be974498-426e-4f43-9e03-2842b5932cb2', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1285, '62031DB3-5B18-4998-A455-B79B254642A7', null, null, null, null, null, null, null, '9ec19092-edda-4ecc-8bf6-35f51ef69d53', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1286, 'CE338614-99DD-4EB2-8F58-957A4B2D9E54', null, null, null, null, null, null, null, '8d2a0a97-2abe-4d3e-a823-425631d29f3e', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1287, '12EF8549-96CE-48A7-98CC-940714967696', null, null, null, null, null, null, null, 'd3741ea4-6b35-4074-aa55-66c11bc934c6', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1288, 'D60C92E5-2265-4E9B-9DB7-8AD123487A2D', null, null, null, null, null, null, null, '1d216951-e682-4652-a4ae-c5272322e551', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1289, '496AC5EB-6FE3-4BB6-9560-83F1A0F370E6', null, null, null, null, null, null, null, 'c32d3b42-4d35-4568-af02-2a60d2964dc7', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1290, 'E4882B61-5680-4B15-8EAB-95DACDC4E5E2', null, null, null, null, null, null, null, 'bb8b3b1c-35b1-49ba-b3b0-b7688e5b9ca5', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1291, '066DB722-FF2E-46F9-B6D7-B31D0AA3AE09', null, null, null, null, null, null, null, '393c3c0d-5516-494a-af38-5df6a3f6217c', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1292, '58592F2B-9167-4960-B236-B84F60CE4C85', null, null, null, null, null, null, null, '49b9e03d-febc-4137-861d-d44bef494d10', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1293, 'E32FD7BA-C7D2-4A6C-B8F7-B6C3AB6F0B6B', null, null, null, null, null, null, null, '1ba39fa2-2c0c-4006-b8fd-8561d8751f23', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1294, '42B5BA8E-EB36-4A1D-8574-A71D959AA983', null, null, null, null, null, null, null, 'dd3b9acc-5432-4b9c-8b03-00bfe3bbbb4a', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1280, '690A8F23-0A4A-4655-9F08-BE0F6993C29B', null, null, null, null, null, null, null, 'df1dced2-5c5b-4bfd-adfd-129d02a496bc', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1281, 'A17628BD-E74C-4E4A-A1EE-B628CEF1CD33', null, null, null, null, null, null, null, 'd0b41a25-65cf-44c4-bc89-b77939f4b797', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1295, 'BDDBD748-5AC9-4CA2-A894-8D2B723017F9', null, null, null, null, null, null, null, 'f8b22880-b94c-418c-9127-43babbc0be40', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1296, 'DA95E46C-1151-4675-A2CD-B7BD6130D8F1', null, null, null, null, null, null, null, '82076303-d694-47e0-b23f-ac2a3df2750e', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1297, '08C525B8-95E2-450A-80A4-BD64C3A248F5', null, null, null, null, null, null, null, 'b5e69dea-b288-4efa-814c-ac1aaa4c5c74', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1298, '54E8D67C-3B35-4A17-8B6F-AAAA630AB59F', null, null, null, null, null, null, null, 'f9d4febf-140d-420f-8ee8-615811d0096a', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1299, '3DB33043-90FC-4606-9E1E-A607F955D4AB', null, null, null, null, null, null, null, 'b96b4b09-f773-471b-83f8-16c4b3d261b3', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1300, '6C5A304C-4FDF-402B-9C77-BA187D7B5B46', null, null, null, null, null, null, null, 'E916A191-363F-409F-BA8B-4F2A661481FA', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1304, '012acdcb-6729-4d2d-ae3b-e3eee4648189', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '9ec19092-edda-4ecc-8bf6-35f51ef69d53', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1188, '169c17d7-f878-4a90-b34f-fa42ae70a70e', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '49771b10-a421-4ea6-a810-7cdcd851babd', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1189, '86fa250f-d321-4927-a9e4-fa36f7e78356', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'BE2E43A2-F7A1-482E-9071-999E84B510D3', 1, 'cc735573-de13-4ef4-a4c3-49f7e989c5c8', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1191, '53536a0c-ca09-4966-9299-e2cda67e4b6a', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '02AA513B-3A10-4A58-9F45-9EFBAD093755', 1, 'cc735573-de13-4ef4-a4c3-49f7e989c5c8', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1192, '3881d28d-ab64-49fe-a729-13477cff4ccf', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '5667ABEB-0AD2-E69F-E050-E050A8C00301', 1, 'cc735573-de13-4ef4-a4c3-49f7e989c5c8', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1193, '70507299-7d76-4b31-b3d2-56f2d2dfd417', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'b10688c5-12a7-47cc-bd2d-85fa0dda8bb0', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1194, 'b6cde7d0-32e5-409e-b7ab-470d5bd8bda7', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '1b1253af-3c57-4318-ab57-6d0c12906c27', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1195, '8e1a0727-4838-42b4-b6cd-f20a1f06c1b6', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'bd0f4a52-805a-41b5-99ed-a62ce922fb42', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1196, '5c933288-c1dc-4309-af54-7e511dc45c31', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '69F8B25B-0F3E-4D98-987E-4C6B08F952E7', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1197, 'f57c661b-41ae-4b5b-b91b-346115f1561b', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'bac50593-8dea-471c-b0fd-c8718d5debe8', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1198, 'd91f7545-40b1-4d81-8fe9-485a71c4e1ce', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '7221a67b-e8c5-4612-80da-e42f7ff119a0', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1199, 'fe5cc88d-4628-4bfa-9bad-8190f9a3e7dd', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'b7bcc7f1-12aa-4323-9ce9-0074150abee2', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1200, '26df6951-3989-4488-950c-db5734d07ddb', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '9d304881-3fc3-4881-8c52-ef6aea72059e', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1243, '8301647d-9136-44f5-b518-f5d6ceb7e32e', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '1340CBF9-2C05-4472-A07C-9952BAF6EA80', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1244, '32c993ed-eedd-4416-8c6a-60afbf4973dc', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'f8ec5be7-affd-4aa8-bf74-3c473bf942ef', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1245, '870ab4f7-2a1b-4578-ad1a-3f826ffa2a82', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'd91123e8-2757-40e7-8735-d69eb62e4d36', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1246, '4bdbc29f-7fec-42a1-8f70-3d487c530144', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1247, '2dfe7e5e-b030-4636-b558-d1ee3a044e6e', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '217C6E9E-2FB3-4386-A05D-1A97ACF878AF', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1248, '028341aa-ca18-4a8c-a592-6114f498970f', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '9EF3B0DD-7E7C-4067-BAFE-C7382208F98A', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1249, '541bc50c-37c1-4ab8-a6d2-ec4fd7477c6d', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '1935538E-C30C-4D0D-AFD8-BD7E8D2A9487', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1641, 'D9937502-550E-47EE-8A20-9EA2EC438D52', null, null, null, null, null, null, null, '629693E5-9BD3-40EA-8B32-9346F3B396D4', 1, 'C1752055-CA52-48D3-B858-9639BDE13B20', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1647, 'c216433c-4d7f-42c5-b28c-7d43977af5af', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '4cb9ca43-a27b-449d-9880-505b4036e991', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1648, 'af851af2-c645-4d4d-9179-f1cd5ca8830c', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'd8279286-47d7-4c06-a60a-960179314800', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1649, '51F7C513-3E64-4FB0-BC38-AB59DB463972', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '8478ef47-8f2f-4d07-9e14-e9dd15d0d86b', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1650, '7E9AC906-5F4B-4B45-A04C-9B66FA447E9B', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '2d5201a4-9722-4de8-9f9c-fcf53e605856', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1652, '45766d8e-08fe-4453-a8ba-feba4e8a1a05', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '88da4e07-1225-4e1f-a353-e5eb1ed8814e', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1654, '011AE513-F1F1-4D08-A595-9A16DC32661D', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '17b3303c-7ca9-46c5-aa09-1be77caf652a', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1663, '9FD13605-2053-4320-A34F-9D4E0AEE25B4', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '9272132D-D2CB-4DB9-A842-962673F55E9C', 1, 'cc735573-de13-4ef4-a4c3-49f7e989c5c8', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1664, 'FB5205DC-99F0-4BA5-B629-A16CA3F0AD94', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '160b3233-5528-491a-b4e4-f20a7f211d74', 1, 'cc735573-de13-4ef4-a4c3-49f7e989c5c8', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1665, '7B8F8D03-D9E7-481E-9BD7-8C5C704820D7', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'a26a5caf-1b3b-4780-8f96-cd2853ccbfc9', 1, 'cc735573-de13-4ef4-a4c3-49f7e989c5c8', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1666, 'C38E5041-FF5D-4CA8-A131-8C3965A563BF', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'e0bd7983-9c88-482c-8179-989f252fc8c9', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1667, 'A6761C67-14C1-44D5-ABA7-813AB225E7F3', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '9c02fbd8-d95e-42c6-9925-edf8013f162d', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1201, '3e7be2bb-0bb4-4d04-8634-0e6a4284d29c', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'E2701565-A228-42EE-9872-35353E90244B', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1202, '7379014f-fc0d-498f-9376-4fd4c5d15dab', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '49DC9281-E1A9-43E7-AC94-10CBD3FF2DE0', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1203, '69f1c4a8-cb31-437f-96af-cc506e3ec0e2', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'F1703306-D10E-4D72-A45C-56026702EAFB', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1204, 'c536727a-0ef6-4c48-9f97-ff374f026527', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'D4597E98-305C-42C8-AD88-7BB81B99C1CC', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1205, '14131513-2c65-451e-b282-03690545c3be', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '8e3a8027-e0f0-4e44-9fa5-e6a1c5611781', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1206, '981c3468-c005-41e2-9027-55743671fade', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '86c0d1ae-2936-43bb-8fc0-cae5c8b7c849', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1207, '0e203be8-92ec-479b-a96a-c91019b15f50', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '51b1d949-dae7-4fea-8a49-549fa7aca658', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1187, 'b571014d-727f-402a-99f6-67d6407e4244', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'BADF62F4-1FAB-4456-8CFB-1F1647C31D27', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1208, '669a7d00-5546-4ba3-870d-4a4ac5c2d270', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '4e1cdf75-f333-40a7-b2b2-65c95ce4bbe6', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1209, 'dc183ebc-9960-45bf-b821-c613dd2502db', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'e6c0e428-5ebd-4d62-8a6c-066e757c444a', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1553, 'ca197b44-a262-406e-b9a5-c76c84985969', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '43c242db-23d2-43fe-b8e4-6da6610ecd6e', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1210, '9834d93c-7e7d-4a53-9cf1-1b3f7c97d7b0', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '632648bf-74d2-4df1-ab0e-d5bc83e5a66d', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1211, 'ff5f2974-a3a0-48ce-8f93-459a546c4928', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '72c6e3cb-bd7c-4cbe-b603-7128102b0609', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1212, 'b4d70f90-8c4d-4dcf-866c-13eff3c0a4ca', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1213, '29ac2647-54cd-4420-a674-48f1c7cd045f', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '568cb299-39ea-401f-8146-547e46f3cbd8', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1214, 'c0d3281a-4d60-4d4f-9d6c-ad2b9aec01c7', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'CD5EABD5-50BA-470D-A075-94CDD29710D0', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1215, 'e923534e-94c0-4309-851d-a55d35b9fb5b', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'EAB8A05E-ACAA-4973-B077-F034E2E09707', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1216, '30c57e0b-0763-418e-9d6f-00b3a2fc3a31', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'C7AE9333-ED9F-4A24-837E-0600967C1D07', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1217, '05b6d12e-ee9c-42d3-a6e8-a33c3684708f', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '0162c5d6-0d60-46fd-b800-dfafb5452e84', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1218, '340e2032-f1ad-4135-91cf-11bba79fb42d', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '03ea9dd8-fab6-41b3-9bf7-bc70e582a743', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1219, 'c5a33c60-3217-4457-ae91-6e8dbb5c4687', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '593776a1-17d7-4915-9d27-761e9747a42d', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1220, '3f9db16d-634d-49d7-8c24-19ea2622fdd2', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '80a3f1e8-d48c-4bd5-9ffc-7690bf276eb5', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1221, 'acec8c12-2884-49a5-9bf7-f65b004bac81', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'fcde4eb5-e39c-4fc4-bcfa-12182e702355', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1222, '91919f81-2d77-45fc-a0d1-de222a6256f0', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '108f1c67-ac1b-4b62-9c88-bac470d6af42', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1223, 'cccac0b2-7f6f-472d-ada6-61057fe4e767', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'd5809727-f108-41ae-894c-66658d6eb7fb', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1224, 'dd380612-c781-4a1d-8b6c-f62ef0f76b68', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '4FAC7F8A-7745-413F-B1E5-C20A548691B7', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1225, '95876d33-dc4b-456a-bf59-7e2eebe4258b', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'd7dc85a2-34da-42ab-b2e5-31e6edb82e5f', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1226, 'c78e1823-86a9-42ff-9f1f-7dae20d81610', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'ee706728-edc7-497f-8a28-30265c680fba', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1227, '4881af77-780a-4254-a2de-6fefd1fc0e76', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '7E7D87D9-68E3-409A-9C86-20DBD31F85AA', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1228, '8b15857a-3640-4457-a6e4-ad590312e3d6', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'F53B7513-3B2B-44A2-AEBB-C96E51354CE3', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1229, 'a66518b0-3e13-4d9f-bb43-f294283d902b', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'A690AAF5-E0D9-4F5E-8F20-976967D70CBA', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1230, '82a4798e-012a-4267-b719-cdad00a7f52b', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'F537B4D9-211C-4690-BC44-C8F5ED2D2737', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1231, '21347e9f-ec94-4a59-ba54-de35ebea6950', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '7DFD03C9-853E-4096-ACF7-A9241A3FC5D5', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1232, '54261048-a6d1-4eaf-8987-fd08aa6be04b', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '3ec3c941-e2fb-4acd-b03a-bb3887635a7e', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1233, '7e99c7f7-5f91-45d3-a53d-bbb635b084de', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'B37327C9-FD09-4091-B152-830CC919E0A8', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1235, '49a6eedf-c628-4f4a-a321-1746a40397f6', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'AB871E14-652C-469B-BA16-B586B09188C6', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1236, '961b0f3f-b36b-405a-ae14-562f1a9217e2', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '9464daaf-9415-4b5a-bdb3-2614bf2d88bb', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1238, '53d298c9-814e-483b-8fb1-be0dbd5cf33d', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '69F8B25B-0F3E-4D98-987E-4C6B08F952E7', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1239, '7d7e46a3-8095-40c0-863c-845180dcb0ab', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '33cc45dd-51fe-4d28-8f8d-a3122dbabdc2', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1240, 'd7699173-6fd9-491c-8f5f-76805dda3c6d', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'b4103fe8-a7be-4655-a965-da1a6386f47d', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1241, '2691b912-52f7-4971-afad-84adffdd3d20', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '112ba525-c0b6-45c5-b9b8-cf3200d20012', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1242, '9b1f8f83-362e-44b9-9208-8c6380f83bec', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '9d147bc0-a473-4b83-9f90-4dee0794ab92', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1787, '10eb8640-6767-4dc0-aba4-46b9bd65ef38', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '3683620d-48a9-40a7-a482-a979c98485bd', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1788, '8fce7ca4-ecb5-4a3f-af01-528f55af757c', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'a19b6679-90ae-42cd-ab79-9b7e7f6d494e', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1789, 'ff623987-76a8-45ae-b1a4-9897cb724085', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'b887d6a9-5a7f-4ea7-a16e-761218838b18', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1790, 'c14897ed-300d-4442-9826-f788d5e80526', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '910f38e0-5bb0-4872-ac86-8a431b305133', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1791, 'f3f75c06-7d00-41a9-92ff-d54a43683943', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '1bc3ebbc-3dc5-4468-bb01-a28070356ef9', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1792, '40eab7ed-42ea-498a-8bb5-b482160a9c06', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'c35ff2e9-e7d5-4c90-9160-c3700fa88325', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1813, '06ec391d-9f1e-4d6e-b48c-5c8d30c8516a', null, null, null, null, 0, 2, null, 'e8819ac8-6f00-4a9a-bc09-19921990d7dc', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1814, 'e1948842-bd20-44a3-a030-8dde9c9ac5ab', null, null, null, null, 0, 2, null, 'af8829ec-9820-4b2f-ace7-7b1628a2686e', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1817, 'd30e5c5a-0d85-446d-97c7-e8501591976a', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, '245633d5-f7cb-4a87-b24a-5913f7eb240d', 1, 'C1752055-CA52-48D3-B858-9639BDE13B20', 2);
INSERT INTO DCC_ACE (ID, GUID, AGENTENDTIME, AGENTGUID, AGENTSTARTTIME, MANAGEREALMGUID, OPERATIONMASKS, PERMISSIONTYPE, PRIORITY, RESOURCEGUID, RESOURCETYPE, SUBJECTGUID, SUBJECTTYPE) VALUES (1818, 'e5e556f1-fe67-488c-a069-6778f4f7de4b', null, null, null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', 0, 2, null, 'e0aa298c-6d3f-42af-91e6-943b8099d6b0', 1, 'C1752055-CA52-48D3-B858-9639BDE13B20', 1);
create table DCC_APP
(
    ID               integer        not null
        primary key,
    GUID             varchar(38) not null
        constraint UK_G44WKIQSWBBMXIA4739JHQCWV
            unique,
    K_NAME           varchar(190),
    REALMGUID        varchar(38),
    REMARK           varchar(255),
    SORTNO           integer        not null,
    NOTIFIEDUSERGUID varchar(38)
);

create unique index DCC_APP_INDEX_K_NAME_UINDEX
    on DCC_APP (K_NAME);

INSERT INTO DCC_APP (ID, GUID, K_NAME, REALMGUID, REMARK, SORTNO, NOTIFIEDUSERGUID) VALUES (-1, '43972DD7-CF57-46AF-9D60-CED094C9E738', 'DASC', 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', '数慧应用安全中心', 1, null);
create table DCC_APP_HEALTH_CONFIG
(
    ID            integer   not null
        constraint PK_APPHEALTH_INDEXKEY
            primary key,
    GUID          varchar(38) not null
        constraint PK_APPHEALTH_GUID
            unique,
    APPGUID       varchar(38),
    NODEURLPREFIX varchar(256)
);

create index IXFK_DCC_APP_HEALTH_APPGUID
    on DCC_APP_HEALTH_CONFIG (APPGUID);


create table DCC_APP_MANAGER
(
    ID       integer        not null
        primary key,
    GUID     varchar(38) not null
        constraint UK_486A6G0GGW3IQEMD76XPTL1XH
            unique,
    APPGUID  varchar(38),
    USERGUID varchar(38)
);

INSERT INTO DCC_APP_MANAGER (ID, GUID, APPGUID, USERGUID) VALUES (1329, '2D488E6B-32B9-4D65-AACB-A364462B44DD', '43972DD7-CF57-46AF-9D60-CED094C9E738', '85A2EE39-A64A-40AD-B9B1-A2389AA6A1AD');
INSERT INTO DCC_APP_MANAGER (ID, GUID, APPGUID, USERGUID) VALUES (1330, '5587F6F8-156B-42C9-9144-866D84B5DC79', '43972DD7-CF57-46AF-9D60-CED094C9E738', '67C42486-97B0-4112-8D92-A39C6C683D54');
INSERT INTO DCC_APP_MANAGER (ID, GUID, APPGUID, USERGUID) VALUES (1331, '97BE8967-7BBD-4C24-800C-B586F687DE3A', '43972DD7-CF57-46AF-9D60-CED094C9E738', '057293DA-90DA-4CCC-A253-BDFE61CD4DDD');
create table DCC_AUDIT_EVENT
(
    ID        integer   not null
        primary key,
    GUID      varchar(38) not null
        constraint UK_5DW40D6GYRN84RXNCJEIROLRM
            unique,
    MARK      varchar(8),
    K_NAME    varchar(60),
    REMARK    varchar(255),
    SERVERITY integer,
    K_TYPE    integer
);

INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1671, '017B70C8-9A7B-44E1-9FDF-B7715BD2E9A1', null, '调入', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1672, '027A27A7-5D15-4FA0-ADDC-A73CEA5D9548', null, '增加职位人员', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1673, '02E102A1-E833-4E01-BA83-B05C211E7C6E', null, '新增用户', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1674, '055C9A13-0C60-4E8F-953F-A791C594453C', null, '用户恢复', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1675, '0D0C72D5-8AA1-46A7-9E1E-801134C49EF3', null, '删除岗位角色成员用户', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1676, '0F9153BB-1A45-474E-A1D6-83A87EFB9C7E', null, '取消应用管理员', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1677, '0FB6699B-7FA9-44F4-8961-B64570808838', null, '添加功能', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1678, '175D3846-6FBC-434C-AA49-A4437024C103', null, '删除系统角色用户成员', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1679, '189C45AA-423F-4C9E-AFEA-ACD3DF747652', null, '健康监控', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1680, '1E177D34-F5EC-4F66-A886-BE20AA55E5AF', null, '用户挂起', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1681, '204BCE58-0A92-47D7-9572-A339FDAF0FA4', null, '定时任务管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1682, '20FF4372-FAED-4A5C-968B-9FDDFD2EF3AF', null, '角色管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1683, '213D7E3A-90C2-4E9D-825C-B69E96D28506', null, '设置应用管理员', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1684, '23000C46-0396-457B-9BB0-829D7B817EB4', null, '管理员重设密码', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1685, '279CB2D8-8A21-40D3-8FDD-905DF0EC5AE0', null, '设置用户离岗', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1686, '28457DD5-B6E7-47F2-9B9A-9A4F3E27B5B6', null, '删除功能', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1687, '29B51A59-A53D-416A-AB58-93B4A34FF04E', null, '增加禁用登录验证码用户', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1688, '2B4DA22C-866B-4526-BAAA-A19077567ADD', null, '添加系统角色成员角色', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1689, '2B5EF8ED-2A81-43D8-AA49-B7D0ACD58846', null, '预警通知管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1690, '31C9DD2B-0208-4B3A-866E-88C7959F6590', null, '查询审计日志', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1691, '37CA1B27-9980-46C7-BC4B-B7CB418DD008', null, '应用功能管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1692, '38045DFD-9442-48E4-88D0-98D2A93CB694', null, '应用管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1693, '395B7E11-4BCC-4067-964D-BE534DC23793', null, '岗位角色成员管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1694, '3A07CF53-5755-4150-9F95-AAC7A140443E', null, '机构管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1695, '3A857864-2713-4E21-AE2F-93F807DB9096', null, '设置域管理员', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1696, '3DB017D2-22DE-4F55-8450-8C2F8C3F7E05', null, '职位管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1697, '4353A20E-741F-4C8B-AD75-B2CC074290CD', null, '修改角色', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1698, '4A817396-00E9-459E-BDC5-99BAE5DB31D7', null, '登录', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1699, '55015F0A-D294-4C5B-B06D-BB5F134BE197', null, '设置安全策略', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1700, '5C428767-6778-45CC-938A-B1D6C243D210', null, '注销', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1701, '5F63891D-0C51-41B8-8841-BD24CDF6EB58', null, '删除域', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1702, '65160464-0C79-4583-B3AA-9205A6A51669', null, '修改域', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1703, '6707DC86-5593-4863-AA48-A170512029AA', null, '添加用户到机构', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1704, '6C82C881-DBAD-40AD-B37A-9FEAC2EA012A', null, '添加岗位角色成员角色', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1705, '710EA2F1-AB95-4AE4-BD43-A35B2CDA5C38', null, '强制注销', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1706, '735DD3E8-A705-4735-8773-853D085044A6', null, '修改应用', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1707, '748CF929-BCF6-4758-ACD2-9385E60634C1', null, '挂起机构', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1708, '757BEE8A-E690-4795-8DFC-B5910394EC82', null, '个人添加代理人', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1709, '780F73FF-514D-450E-82BF-9BE30877D766', null, '同步应用管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1710, '7C2EA9EB-C139-4C3D-B413-B92B52D4E3CF', null, '角色授权', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1711, '844F3122-A28F-4614-B070-9E79D68CF030', null, '职位人员删除', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1712, '8595A573-F994-4267-BBD0-A9B714454245', null, '用户权限来源', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1713, '8A3172DB-FF5E-43C5-B584-B37CBD4785A3', null, '添加系统角色成员用户', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1714, '96D142F6-A6EF-4101-9392-9CB9E053F54D', null, '删除岗位角色成员角色', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1715, '99F1BC25-C27B-4224-93B9-95C6D95D5DD2', null, '删除应用', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1716, 'AC954315-6D34-460C-9360-AB6F93DB8D72', null, '移除域管理员', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1717, 'B0837A70-7A89-4C01-8C74-BCEC7C1E4CB9', null, '设置用户权限', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1718, 'B2169BE6-2364-43A1-90A5-872E20193830', null, '数据导入', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1719, 'B67C4E28-3F60-4BFF-BDD3-871B3FB69DC5', null, '汇总日志管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1720, 'B87764FF-FC58-4CD4-B9A1-8E82EFB2F918', null, '同步任务管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1721, 'BB679399-9ABF-417F-B3A5-96071C5DB5AB', null, '用户授权', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1722, '02EB35DD-96B0-4EFD-8E10-B2AA945D6607', null, '机构用户管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1723, '08383C90-ADA4-4712-9C77-80CD606BE039', null, '删除职位', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1724, '0BD84C06-C929-4D65-97CE-945E3BAB8415', null, '安全策略配置', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1725, '0BF6390D-7461-4A83-BA65-AC7F6DFFE03B', null, '删除角色', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1726, '0C625B8E-2772-4385-80DC-93D612752D51', null, '修改机构', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1727, '131C1161-822F-498F-B057-B413D91C1897', null, '修改用户信息', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1728, '143D55EC-2B0A-4E65-80A5-96E732B012FC', null, '删除系统角色成员角色', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1729, '149383AA-9CF8-484B-8575-B52134049D57', null, '修改用户岗位', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1730, '15A50AF6-5CD5-4A1D-989F-8080BF1371FD', null, '将用户从机构中删除', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1731, '1798722C-8B24-436B-A2D3-951A259740EB', null, '服务器存活检查', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1732, '183424FC-14DA-438C-B317-AD70DCB3BBCE', null, '修改个人密码', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1733, '1961D258-02E0-44B9-B85E-ABCEB77986B9', null, '登录验证码禁用管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1734, '1A426AEA-4F6E-4DAA-855A-A2DE0B20C8AC', null, '系统角色成员管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1735, '25B6B29C-D23A-4EE8-87E7-AA89A1E5472D', null, '审计日志统计', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1736, '26ADDAF2-C97B-4D9A-AB9E-B485CD2806E3', null, '新增部门', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1737, '272244B6-A672-47FA-8DB6-A887450BC7D2', null, '添加应用管理员', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1738, '30175B64-3A36-407D-8251-B0600EF5E00B', null, '添加用户代理人', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1739, '311FCA59-3293-45B8-8D9F-8CD2DC8319DE', null, '删除用户代理人', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1740, '34AE0440-1E65-4F30-8AE7-8ADA8104FC64', null, '恢复机构', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1741, '36038D00-62B5-44FC-BF7D-83FDAE2278FB', null, '用户管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1742, '3646311D-AD07-42CE-A111-AA3CB580BBE2', null, '审计报表下载', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1743, '3FAFEA12-87EF-473F-B888-95A65F01F8EC', null, '用户实际权限查询', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1744, '410B00BF-80D9-4907-A58A-90930409EB32', null, '个人代理设置', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1745, '470BCF1C-E25F-46AA-8B62-AEFD4A5ED311', null, '用户调入', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1746, '47B772A9-E302-45E7-ACAE-89E5D797B7D2', null, '撤销机构', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1747, '4E72282E-FDED-418D-BCED-B4F340FE6A60', null, '强制修改密码', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1748, '516EC618-EAAC-46BF-8AF8-843C6AA7465A', null, '新增域', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1749, '55A1D003-C9F7-447C-B0D6-A5F9EDEBA329', null, '新增角色', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1750, '58FF0800-DF7E-4138-A66B-A95B730302E2', null, '新增域管理员', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1751, '6436775A-A1B0-4886-AE37-97B8663DBA81', null, '添加岗位角色成员用户', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1752, '6588CF20-6158-4E97-AF63-9D9AFC47E0C3', null, '新增应用', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1753, '6C7577B4-BFF8-4086-8412-892ACF8FC48C', null, '删除系统角色所属角色', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1754, '6D478C42-D671-4C47-96C1-9DCDEE1B070F', null, '新增职位', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1755, '766BF725-A4AE-4EA8-BE72-AEAA6EB9DD55', null, '已登录用户管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1756, '77AC75B7-4156-428D-967B-9A862ADFBA6F', null, '修改个人信息', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1757, '79AEEF0A-8598-497F-9643-959A30B39311', null, '下载审计日志', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1758, '7B3503EF-E332-4538-8227-BBA10B063E79', null, '删除代理人', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1759, '7B86E350-F8AD-44DC-9AAF-8FF5CE4EFF07', null, '用户调离', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1760, '7D4A8C28-EED1-4AF7-8FC7-B183F9A8778C', null, '新增机构', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1761, '7E958476-D52E-46EB-8243-AEB224FEAD25', null, '设置角色权限', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1762, '8714A8A7-7D92-4A25-8594-A418744C2E52', null, '添加系统角色所属角色', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1763, '882CFC5B-5BF2-449D-92B1-BA88EB33062B', null, '修改功能', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1764, '8F6113B3-571F-4C4A-9C90-B18F44E12ABE', null, '删除禁用登录验证码用户', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1765, '8F615424-06D9-4B7F-A78B-863CB74074CA', null, '修改职位', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1766, '8F946537-9420-40A7-9159-B8D9AA4DE9C4', null, '详细日志管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1767, '9359AC06-494B-4672-9483-B38C721A2E74', null, '域管理', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1768, '94FB964F-E88E-4869-B10F-8C32E31C7483', null, '审计日志查询', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1769, '9D02D94C-777C-4D59-8D89-833C9AE89D52', null, '个人信息', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1770, '9D57BAF7-475A-4401-8702-9254FE9EBE03', null, '设置密码', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1771, '9F412B70-1B0C-4EBC-B45A-A66552C919DA', null, '解锁用户', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1772, 'C8B21764-D6CD-4ED0-965C-A0AE995B2ED0', null, '服务器内存使用率检查', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1773, 'BD033EDA-4F7D-45C8-840C-AD415A80EFB3', null, '服务器CPU使用率检查', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1774, 'AEFFCCAE-A9D3-4122-A18A-8EE0CD412CB0', null, '服务器网卡使用率检查', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1775, 'E0F27EBA-0866-4D59-B0A6-A5F060E0A17E', null, '服务器磁盘使用率检查', null, null, null);
INSERT INTO DCC_AUDIT_EVENT (ID, GUID, MARK, K_NAME, REMARK, SERVERITY, K_TYPE) VALUES (1776, '66053950-A2B4-4DAE-9DC5-986F1798AEC9', null, '应用存活检查', null, null, null);
create table DCC_AUDIT_LOG
(
    ID             integer               not null
        primary key,
    GUID           varchar(38)             not null
        constraint UK_694UE95UUU3YR1DYQSKCDXSYX
            unique,
    AGENTGUID      varchar(38),
    AGENTLOGINNAME varchar(60),
    AGENTNAME      varchar(64),
    APPGUID        varchar(38),
    APPNAME        varchar(60),
    DIGEST         varchar(64),
    EVENTGUID      varchar(38),
    EVENTNAME      varchar(255),
    FINISHTIME     TIMESTAMP(6),
    REMOTEHOST     varchar(50),
    REMOTEIP       varchar(50),
    PARAMS         text,
    REMOTEPORT     integer,
    REALMGUID      varchar(38),
    REALMNAME      varchar(64),
    REMARK         varchar(255),
    RESULT         text,
    SERVERITY      integer,
    SERVERITYNAME  varchar(64),
    STARTTIME      TIMESTAMP(6),
    URL            varchar(255),
    USERGUID       varchar(38),
    USERLOGINNAME  varchar(64),
    USERNAME       varchar(64),
    EVENTTYPE      integer,
    URI            varchar(255) default '' not null,
    ELAPSEDTIME    bigint    default 0  not null,
    SUCCESS        boolean     default true  not null,
    SERVERNAME     varchar(64)             not null,
    SERVERPORT     integer                not null
);


create table DCC_AUDIT_STATISTICS
(
    ID                 integer   not null
        primary key,
    GUID               varchar(38) not null
        constraint UK_4IYRE0DWAW4B405Q87DRYF575
            unique,
    BEGINDATE          TIMESTAMP(6),
    COUNT              integer,
    ENDDATE            TIMESTAMP(6),
    EVENTGUID          varchar(38),
    EVENTTYPE          integer,
    PERIOD             integer,
    USERGUID           varchar(38),
    REALMGUID          varchar(38),
    DIGEST             varchar(128),
    AUDITPERIODNAME    varchar(32),
    APPGUID            varchar(38) default ' ',
    URI                varchar(255),
    AVERAGEELAPSEDTIME bigint
);

create index DCC_AUDIT_STATISTICS_INDEX
    on DCC_AUDIT_STATISTICS (BEGINDATE, ENDDATE, PERIOD);


create table DCC_BDF_LOGIN_USER
(
    ID             integer not null
        primary key,
    COMPUTERNAME   varchar(255),
    DELEGATEID     bigint,
    GUID           varchar(38),
    IP             varchar(255),
    LASTONLINETIME DATE,
    LOGINNAME      varchar(255),
    SYSTEMTYPE     integer not null,
    USERID         bigint
);


create table DCC_CONFIG_DEFINITION
(
    ID           integer        not null
        primary key,
    GUID         varchar(38) not null
        constraint UK_RSROKQ66IFKF0E3GMKL0SBMBN
            unique,
    DEFAULTVALUE varchar(255),
    MARK         varchar(255),
    K_NAME       varchar(190),
    PARENTGUID   varchar(38),
    REALMGUID    varchar(38),
    REMARK       varchar(255),
    SORTNO       integer,
    K_TYPE       integer,
    VALUETYPE    integer
);

INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1563, '823267F3-E4B4-42C1-8A6A-AB9ED7671711', '288D0113-758F-4ADE-A804-AE76A5CC58F5', 'deleteRelationsWhenDimission', '用户离职是否删除其关联关系', 'AB5143B8-55C5-4A79-B6E6-9545F23AD89A', null, null, 3, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1437, '328af8e4-6311-11e7-8549-00ff14e091ec', null, 'dasc', '应用安全中心', null, null, null, 0, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1438, '328af8e4-6311-11e7-8549-00ff14e091ed', null, 'password', '密码', '328af8e4-6311-11e7-8549-00ff14e091ec', null, null, 1, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1439, '452e9a7e-6312-11e7-8549-00ff14e091ec', '^(?![a-zA-Z]+$)(?![a-z0-9]+$)(?![A-Z0-9]+$)(?![a-z_!@#$%^&*`~()-+=]+$)(?![A-Z_!@#$%^&*`~()-+=]+$)(?![0-9_!@#$%^&*`~()-+=]+$)[a-zA-Z0-9_!@#$%^&*`~()-+=]{8,30}$', 'complexityRule', '密码复杂度规则', '328af8e4-6311-11e7-8549-00ff14e091ed', null, null, 3, 1, 4);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1440, '980376e5-6312-11e7-8549-00ff14e091ec', '30', 'expiredPeriod', '密码过期时间（天）', '328af8e4-6311-11e7-8549-00ff14e091ed', null, null, 4, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1441, 'cf8e1de5-6312-11e7-8549-00ff14e091ec', '1', 'notRepeatedTimes', '密码不能重复次数', '328af8e4-6311-11e7-8549-00ff14e091ed', null, null, 5, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1442, '134faa43-6313-11e7-8549-00ff14e091ec', null, 'login', '登录', '328af8e4-6311-11e7-8549-00ff14e091ec', null, null, 6, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1443, '4e026932-6313-11e7-8549-00ff14e091ec', '3', 'maxFailCount', '失败最大允许次数', '134faa43-6313-11e7-8549-00ff14e091ec', null, null, 8, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1444, '64f56591-6313-11e7-8549-00ff14e091ec', '7b9fe199-6313-11e7-8549-00ff14e091ec', 'permitDuplicate', '是否允许同一账户重复登录', '134faa43-6313-11e7-8549-00ff14e091ec', null, null, 9, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1445, '74c99f5d-6314-11e7-8549-00ff14e091ec', null, 'audit', '审计', '328af8e4-6311-11e7-8549-00ff14e091ec', null, null, 12, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1446, '28c17a20-6315-11e7-8549-00ff14e091ec', '365', 'archiveTime', '审计日志数据库保存期限（天）', '74c99f5d-6314-11e7-8549-00ff14e091ec', null, null, 15, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1447, 'C582E060-9154-456F-9AF9-A3125649A432', '737D9BCB-93EB-4C3A-8B37-BB8FCBF3D1F1', 'separationOfPowers', '是否使用三权分立', '328af8e4-6311-11e7-8549-00ff14e091ec', null, '启用（设置为true）后，只要授予一个用户或角色了一种互斥类型（配置、安全、审计）的权限，将不能再授予其他互斥类型的权限，如：授予了配置类型的权限，就不能再授予安全或审计类型的权限', 0, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1448, '421b0682-2ddc-4ffb-96bf-78862b9b2281', '0b2787a3-9161-44a0-88b7-58ec36147553', 'enableAgent', '是否使用代理', 'AB5143B8-55C5-4A79-B6E6-9545F23AD89A', null, '当为true时表示用户（委托人）可以指定其他用户（代理人）代替自己执行工作任务，代理人在登陆页面选择使用代理后可以选择所代理的委托人', 2, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1449, 'cfa70ac7-d4d6-42d4-b55a-3731193e52be', null, 'authcode', '验证码', '134faa43-6313-11e7-8549-00ff14e091ec', null, null, 27, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1450, '0afad368-4269-480e-81df-1a8a66c2c66b', '21256ebd-77da-44c0-a631-17aaf3b0bb39', 'enable', '是否使用验证码', 'cfa70ac7-d4d6-42d4-b55a-3731193e52be', null, null, 27, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1451, 'e7a4179f-5042-4efe-852a-8649328ea534', '4', 'length', '验证码长度', 'cfa70ac7-d4d6-42d4-b55a-3731193e52be', null, null, 28, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1452, 'd616992c-4973-4305-a2bc-099c2a9eb4d4', '0123456789', 'chars', '验证码可用字符', 'cfa70ac7-d4d6-42d4-b55a-3731193e52be', null, null, 29, 1, 4);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1453, '62ad0bf0-4f5d-47a7-9e30-0f6564601b94', '300', 'timeout', '验证码有效时间（秒）', 'cfa70ac7-d4d6-42d4-b55a-3731193e52be', null, null, 30, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1454, '01428b40-b3f4-44a6-b8e8-f2a25cd727c5', '8c555198-db5d-4a20-8d3e-d351de657dff', 'canOnlyUseOnce', '验证码是否仅可使用一次', 'cfa70ac7-d4d6-42d4-b55a-3731193e52be', null, null, 31, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1455, 'AB5143B8-55C5-4A79-B6E6-9545F23AD89A', null, 'user', '用户', '328af8e4-6311-11e7-8549-00ff14e091ec', null, null, 21, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1456, '8FF9E944-EC79-4676-A654-A4DF126DA470', '75A8F3C9-643B-4E9C-BC7A-B508B3634145', 'mobilephoneMustUnique', '手机号码是否必须唯一', 'AB5143B8-55C5-4A79-B6E6-9545F23AD89A', null, null, 22, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1457, 'cf3ae67e-0601-455f-9e39-9d972aeaaff0', '07e20891-7bcc-442e-ab6e-e3162e1271cc', 'enableRememberPassword', '是否允许浏览器记住登录密码', '134faa43-6313-11e7-8549-00ff14e091ec', null, null, 7, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1458, 'FBA9C761-E330-40A9-9948-8DE08E6EBF88', '93D6368E-4C9A-453A-8A17-861293A2F692', 'loginNameCaseSensitive', '登录名是否大小写敏感', 'AB5143B8-55C5-4A79-B6E6-9545F23AD89A', null, '当为true时表示创建用户、登录时，登录名将区分大小写。由于ldap不区分大小写，当使用ldap进行认证时务必设置为false，否则两个登录名仅大小写不同的用户将会在ldap中被创建为一个用户，从而导致用户登录失败', 1, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1459, '9C4FB4CD-34B3-43A6-AF1D-B40CFD7B1B52', 'F571EF53-8590-4375-AC99-A1DD2F2B5F88', 'complexityCheck', '是否启用密码复杂度检测', '328af8e4-6311-11e7-8549-00ff14e091ed', null, null, 2, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1577, '2B2DEF45-1835-468E-8DEC-BBAE57E4EBAD', null, 'health', '健康监控', '328af8e4-6311-11e7-8549-00ff14e091ec', null, null, 32, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1578, '96D09B96-C72E-4E04-86C6-8FD6D9B66591', null, 'cpu', 'CPU', '2B2DEF45-1835-468E-8DEC-BBAE57E4EBAD', null, null, 33, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1579, '445DD083-2093-45E2-9D2B-B2CF77E910DA', null, 'hardDrive', '硬盘', '2B2DEF45-1835-468E-8DEC-BBAE57E4EBAD', null, null, 34, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1580, '2EE518AB-739A-46AD-91D8-A5ECCDF0295E', null, 'memory', '内存', '2B2DEF45-1835-468E-8DEC-BBAE57E4EBAD', null, null, 35, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1581, '7CD17777-0D8A-4130-99B6-888208FF7F82', null, 'netcard', '网卡', '2B2DEF45-1835-468E-8DEC-BBAE57E4EBAD', null, null, 36, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1582, '5CDEB723-C229-47F0-87E4-AB5B0344CA4F', '60', 'topThreshold1', '一级预警阈值（%）', '96D09B96-C72E-4E04-86C6-8FD6D9B66591', null, null, 37, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1583, 'C00A32CA-EA5C-40A9-A131-984BBD1B494B', '70', 'topThreshold2', '二级预警阈值（%）', '96D09B96-C72E-4E04-86C6-8FD6D9B66591', null, null, 38, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1584, 'C00BE157-FCC1-41AB-AC48-89C8D337831E', '80', 'topThreshold3', '三级预警阈值（%）', '96D09B96-C72E-4E04-86C6-8FD6D9B66591', null, null, 39, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1585, '88E78660-B24F-4AD6-90F2-91C2E55A2821', '3', 'duration', '上报时间间隔（秒）', '96D09B96-C72E-4E04-86C6-8FD6D9B66591', null, null, 40, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1586, '98DB348F-9316-46DA-8448-86AE7A6F81A8', '60', 'topThreshold1', '一级预警阈值（%）', '445DD083-2093-45E2-9D2B-B2CF77E910DA', null, null, 41, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1587, '5F245851-9941-427E-862B-83619B1D9778', '70', 'topThreshold2', '二级预警阈值（%）', '445DD083-2093-45E2-9D2B-B2CF77E910DA', null, null, 42, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1588, 'FDD7B9E0-B9DD-4161-ACE1-BF03D1369D1A', '3', 'duration', '上报时间间隔（秒）', '445DD083-2093-45E2-9D2B-B2CF77E910DA', null, null, 44, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1589, '0D692CF9-D183-456D-AB67-BB64D8714B77', '80', 'topThreshold3', '三级预警阈值（%）', '445DD083-2093-45E2-9D2B-B2CF77E910DA', null, null, 43, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1590, '1397FAAD-4681-4D5F-8D4C-9F535594ECCA', '60', 'topThreshold1', '一级预警阈值（%）', '2EE518AB-739A-46AD-91D8-A5ECCDF0295E', null, null, 44, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1591, 'E8B5D4E8-7A37-4268-BF85-82A78FB6AA86', '70', 'topThreshold2', '二级预警阈值（%）', '2EE518AB-739A-46AD-91D8-A5ECCDF0295E', null, null, 45, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1592, '9B1D30C2-A7F9-4360-B3B4-AAED7FFFF2E7', '80', 'topThreshold3', '三级预警阈值（%）', '2EE518AB-739A-46AD-91D8-A5ECCDF0295E', null, null, 46, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1593, 'A380298A-727D-4B7E-B37A-BFF86423D989', '3', 'duration', '上报时间间隔（秒）', '2EE518AB-739A-46AD-91D8-A5ECCDF0295E', null, null, 47, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1594, '41608722-A35F-478E-9A3E-86669874A3C7', '60', 'topThreshold1', '一级预警阈值（%）', '7CD17777-0D8A-4130-99B6-888208FF7F82', null, null, 48, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1595, '506EC758-1846-423E-A05D-BC67D4310B89', '70', 'topThreshold2', '二级预警阈值（%）', '7CD17777-0D8A-4130-99B6-888208FF7F82', null, null, 49, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1596, '176FCF50-2C80-481B-BDC3-A821E430CCFF', '80', 'topThreshold3', '三级预警阈值（%）', '7CD17777-0D8A-4130-99B6-888208FF7F82', null, null, 50, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1597, '600E7A25-560D-40DA-946D-A15CDF585C41', '3', 'duration', '上报时间间隔（秒）', '7CD17777-0D8A-4130-99B6-888208FF7F82', null, null, 51, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1598, '97F4BE4D-1D88-4448-9BBA-94E0CC92DDD2', null, 'alarm', '存活报警', '2B2DEF45-1835-468E-8DEC-BBAE57E4EBAD', null, null, 52, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1599, '0C9BF1C2-2E7D-4681-B442-B75CAC2E64F2', null, 'level1', '一级', '97F4BE4D-1D88-4448-9BBA-94E0CC92DDD2', null, null, 53, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1600, '56B4526F-2FEE-424A-9078-979CA1F59E7C', '30', 'notAlive', '未收到存活报告时长（秒）', '0C9BF1C2-2E7D-4681-B442-B75CAC2E64F2', null, null, 54, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1601, 'EA32536C-B6F1-417F-8846-8230CBF44443', '3600', 'reportInterval', '发送警报间隔时长（秒）', '0C9BF1C2-2E7D-4681-B442-B75CAC2E64F2', null, null, 55, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1602, '3D953005-16E7-4576-9A52-844AB04837C2', null, 'level2', '二级', '97F4BE4D-1D88-4448-9BBA-94E0CC92DDD2', null, null, 56, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1605, '5D2A133F-A4D8-4888-8021-BB2C713AC127', null, 'level3', '三级', '97F4BE4D-1D88-4448-9BBA-94E0CC92DDD2', null, null, 59, 1, null);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1606, '25883DE2-DBEC-4D62-841A-80BA2F7DC4DA', '1800', 'notAlive', '未收到存活报告时长（秒）', '5D2A133F-A4D8-4888-8021-BB2C713AC127', null, null, 60, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1603, 'BC7F5BDC-6E59-4E69-8940-A43490C35713', '600', 'notAlive', '未收到存活报告时长（秒）', '3D953005-16E7-4576-9A52-844AB04837C2', null, null, 57, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1604, '04E02EC3-E50C-4D22-BB06-BFBDE33B6B8C', '2400', 'reportInterval', '发送警报间隔时长（秒）', '3D953005-16E7-4576-9A52-844AB04837C2', null, null, 58, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1607, 'B12F3D59-04BC-4A58-AC91-9A2A09CB56DB', '1200', 'reportInterval', '发送警报间隔时长（秒）', '5D2A133F-A4D8-4888-8021-BB2C713AC127', null, null, 61, 1, 2);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1669, 'DC957950-0BC1-4B6B-BFFB-908F850668C1', '848E221F-2543-47F6-BD78-BEBC61ECED4F', 'permitKickoutSameAccount', '是否允许顶替已登录账户', '134faa43-6313-11e7-8549-00ff14e091ec', null, null, 11, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1799, '9bbfb49d-d65b-4232-8e7b-1acbada7497f', '9e968ebc-e721-47fa-8193-4dcd7617752e', 'emailMustUnique', '邮箱是否必须唯一', 'AB5143B8-55C5-4A79-B6E6-9545F23AD89A', null, '如果设置为false，将不能使用邮箱进行登陆。', 23, 2, 1);
INSERT INTO DCC_CONFIG_DEFINITION (ID, GUID, DEFAULTVALUE, MARK, K_NAME, PARENTGUID, REALMGUID, REMARK, SORTNO, K_TYPE, VALUETYPE) VALUES (1800, 'd15d5f0a-ce36-4f71-97b8-21e6f20a2509', 'e2c96d34-cdd4-4080-ad8d-aef4fc7a34fb', 'jobNumberMustUnique', '工号是否必须唯一', 'AB5143B8-55C5-4A79-B6E6-9545F23AD89A', null, '如果设置为false，将不能使用工号进行登陆。', 24, 2, 1);
create table DCC_CONFIG_DEFINITION_OPTION
(
    ID             integer        not null
        primary key,
    GUID           varchar(38) not null
        constraint UK_3AOY15UXGQB39A3CJB8C53G9D
            unique,
    DEFINITIONGUID varchar(38),
    ISDEFAULT      boolean,
    SORTNO         integer,
    K_VALUE        varchar(255)
);

INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1460, '7caa4069-f10c-431b-a44a-75a9f3f3f76b', 'cf3ae67e-0601-455f-9e39-9d972aeaaff0', false, 2, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1461, '7b9fe199-6313-11e7-8549-00ff14e091ec', '64f56591-6313-11e7-8549-00ff14e091ec', true, 5, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1462, '7e076f43-6313-11e7-8549-00ff14e091ec', '64f56591-6313-11e7-8549-00ff14e091ec', false, 6, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1463, 'acbdcc6f-6314-11e7-8549-00ff14e091ec', '93033d9f-6314-11e7-8549-00ff14e091ec', true, 7, '登陆事件');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1464, 'c29c762e-6314-11e7-8549-00ff14e091ec', '93033d9f-6314-11e7-8549-00ff14e091ec', false, 8, '登出事件');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1465, '737D9BCB-93EB-4C3A-8B37-BB8FCBF3D1F1', 'C582E060-9154-456F-9AF9-A3125649A432', true, 12, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1466, '6A5E2FBF-BF14-4A07-B3F9-A8024646841D', 'C582E060-9154-456F-9AF9-A3125649A432', false, 13, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1467, '21256ebd-77da-44c0-a631-17aaf3b0bb39', '0afad368-4269-480e-81df-1a8a66c2c66b', true, 14, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1468, '5a6dcc98-2525-4556-89a7-c21589df7aca', '0afad368-4269-480e-81df-1a8a66c2c66b', false, 15, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1469, '0b2787a3-9161-44a0-88b7-58ec36147553', '421b0682-2ddc-4ffb-96bf-78862b9b2281', true, 16, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1470, '1195d18f-d497-4bb6-b288-f74c6bd0ccfc', '421b0682-2ddc-4ffb-96bf-78862b9b2281', false, 17, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1471, '8c555198-db5d-4a20-8d3e-d351de657dff', '01428b40-b3f4-44a6-b8e8-f2a25cd727c5', true, 18, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1472, '8ab01225-bf7c-4aad-99cf-ff859a38af15', '01428b40-b3f4-44a6-b8e8-f2a25cd727c5', false, 19, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1473, '75A8F3C9-643B-4E9C-BC7A-B508B3634145', '8FF9E944-EC79-4676-A654-A4DF126DA470', true, 20, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1474, '68BA5988-E5ED-4C03-9461-91384E0BA8DC', '8FF9E944-EC79-4676-A654-A4DF126DA470', false, 21, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1475, '07e20891-7bcc-442e-ab6e-e3162e1271cc', 'cf3ae67e-0601-455f-9e39-9d972aeaaff0', true, 1, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1476, '93D6368E-4C9A-453A-8A17-861293A2F692', 'FBA9C761-E330-40A9-9948-8DE08E6EBF88', true, 22, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1477, '25D2A41E-6074-46F6-B43B-B9318454F75D', 'FBA9C761-E330-40A9-9948-8DE08E6EBF88', false, 23, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1478, 'F571EF53-8590-4375-AC99-A1DD2F2B5F88', '9C4FB4CD-34B3-43A6-AF1D-B40CFD7B1B52', true, 24, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1479, '58BDB9B8-85F1-4478-BEB8-B8AFDC43CA5E', '9C4FB4CD-34B3-43A6-AF1D-B40CFD7B1B52', false, 25, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1564, '288D0113-758F-4ADE-A804-AE76A5CC58F5', '823267F3-E4B4-42C1-8A6A-AB9ED7671711', true, 26, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1565, 'CF081C1F-D2ED-4575-9F72-A2237F5820A6', '823267F3-E4B4-42C1-8A6A-AB9ED7671711', false, 25, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1572, 'EECE2F13-AF10-42A0-BCF9-8E95797CCF54', 'DC957950-0BC1-4B6B-BFFB-908F850668C1', false, 26, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1573, '848E221F-2543-47F6-BD78-BEBC61ECED4F', 'DC957950-0BC1-4B6B-BFFB-908F850668C1', true, 27, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1801, '9e968ebc-e721-47fa-8193-4dcd7617752e', '9bbfb49d-d65b-4232-8e7b-1acbada7497f', false, 28, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1802, '94aafacb-d51f-4a57-b491-13d09a9df8ce', '9bbfb49d-d65b-4232-8e7b-1acbada7497f', true, 29, 'false');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1803, 'e2c96d34-cdd4-4080-ad8d-aef4fc7a34fb', 'd15d5f0a-ce36-4f71-97b8-21e6f20a2509', false, 30, 'true');
INSERT INTO DCC_CONFIG_DEFINITION_OPTION (ID, GUID, DEFINITIONGUID, ISDEFAULT, SORTNO, K_VALUE) VALUES (1804, '45a1c14e-e8c9-4699-a11c-52dc78981772', 'd15d5f0a-ce36-4f71-97b8-21e6f20a2509', true, 31, 'false');
create table DCC_CONFIG_VALUE
(
    ID             integer        not null
        primary key,
    GUID           varchar(38) not null
        constraint UK_JWJNW79FKFJ6ER7OXYFBPW0X0
            unique,
    DEFINITIONGUID varchar(38),
    OPTIONGUID     varchar(38),
    REMARK         varchar(255),
    K_VALUE        varchar(255)
);

INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1480, '0AC30CAA-5A9C-4B60-8816-A0B87198030D', '452e9a7e-6312-11e7-8549-00ff14e091ec', null, null, '^(?![a-zA-Z]+$)(?![a-z0-9]+$)(?![A-Z0-9]+$)(?![a-z_!@#$%^&*`~()-+=]+$)(?![A-Z_!@#$%^&*`~()-+=]+$)(?![0-9_!@#$%^&*`~()-+=]+$)[a-zA-Z0-9_!@#$%^&*`~()-+=]{8,30}$');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1481, '13685704-5E4A-471D-AF71-A05E716D39EE', '980376e5-6312-11e7-8549-00ff14e091ec', null, null, '30');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1482, '22E0955C-6B53-414E-882C-8014C1CE4CD3', 'cf8e1de5-6312-11e7-8549-00ff14e091ec', null, null, '1');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1483, '235DB4EA-A6BB-4DFC-B7A4-B90AE2F6F00E', '4e026932-6313-11e7-8549-00ff14e091ec', null, null, '3');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1484, '256F7824-C82C-4218-82D6-96E0C3E9E817', '64f56591-6313-11e7-8549-00ff14e091ec', '7b9fe199-6313-11e7-8549-00ff14e091ec', null, 'true');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1485, '3637FE35-0459-4FA0-92F0-B99D6DE810B6', '28c17a20-6315-11e7-8549-00ff14e091ec', null, null, '365');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1486, '39F33524-EC59-48F2-9C6D-A688CE5D7017', 'C582E060-9154-456F-9AF9-A3125649A432', '737D9BCB-93EB-4C3A-8B37-BB8FCBF3D1F1', '启用（设置为true）后，只要授予一个用户或角色了一种互斥类型（配置、安全、审计）的权限，将不能再授予其他互斥类型的权限，如：授予了配置类型的权限，就不能再授予安全或审计类型的权限', 'true');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1487, '5C0B0E2F-02DD-413C-BE6D-9A7E29514B9A', '421b0682-2ddc-4ffb-96bf-78862b9b2281', '0b2787a3-9161-44a0-88b7-58ec36147553', '当为true时表示用户（委托人）可以指定其他用户（代理人）代替自己执行工作任务，代理人在登陆页面选择使用代理后可以选择所代理的委托人', 'false');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1488, '701BCBC0-36F8-4071-A0C8-BACD0B0B0118', '0afad368-4269-480e-81df-1a8a66c2c66b', '21256ebd-77da-44c0-a631-17aaf3b0bb39', null, 'false');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1489, 'A5FEEA99-2472-4250-A73F-8420803AF9FE', 'e7a4179f-5042-4efe-852a-8649328ea534', null, null, '4');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1490, 'AB903D86-6395-472E-B5D3-967806A99D4C', 'd616992c-4973-4305-a2bc-099c2a9eb4d4', null, null, '0123456789');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1491, 'CA39CD7D-78E4-4B39-8B65-A112A7B13184', '62ad0bf0-4f5d-47a7-9e30-0f6564601b94', null, null, '300');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1492, 'EA2D98D4-7D54-4EA6-89C6-8DCC25FCC117', '01428b40-b3f4-44a6-b8e8-f2a25cd727c5', '8c555198-db5d-4a20-8d3e-d351de657dff', null, 'false');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1493, 'EE1E2F57-EF7A-4837-AABB-84EC96ECAACE', '8FF9E944-EC79-4676-A654-A4DF126DA470', '75A8F3C9-643B-4E9C-BC7A-B508B3634145', null, 'true');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1494, 'EFF6993A-82E3-4A2B-ADD6-AC81B010C009', 'cf3ae67e-0601-455f-9e39-9d972aeaaff0', '07e20891-7bcc-442e-ab6e-e3162e1271cc', null, 'true');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1495, 'FE0867B4-98B4-4729-B72F-9771247C6E35', 'FBA9C761-E330-40A9-9948-8DE08E6EBF88', '93D6368E-4C9A-453A-8A17-861293A2F692', '当为true时表示创建用户、登录时，登录名将区分大小写。由于ldap不区分大小写，当使用ldap进行认证时务必设置为false，否则两个登录名仅大小写不同的用户将会在ldap中被创建为一个用户，从而导致用户登录失败', 'false');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1496, '19A4EC9A-2D77-4C4E-A033-8FA1F2926DBC', '9C4FB4CD-34B3-43A6-AF1D-B40CFD7B1B52', 'F571EF53-8590-4375-AC99-A1DD2F2B5F88', null, 'true');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1609, 'C5F7909B-8FB2-4C27-9B1E-8D2F9CB36F2A', 'C00A32CA-EA5C-40A9-A131-984BBD1B494B', null, null, '70');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1610, '7835DBC4-C4DE-44C4-B8A9-854F48EDAA67', 'C00BE157-FCC1-41AB-AC48-89C8D337831E', null, null, '80');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1611, '4DF15365-BB69-42EB-98A1-8F48402444CD', '88E78660-B24F-4AD6-90F2-91C2E55A2821', null, null, '3');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1612, '899361E5-ADD6-469F-B1B9-833B040AA6AE', '98DB348F-9316-46DA-8448-86AE7A6F81A8', null, null, '60');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1613, '983C1C5F-3CF1-47E2-AC76-A73AA84C948A', '5F245851-9941-427E-862B-83619B1D9778', null, null, '70');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1614, 'C5D6689F-43C1-498C-9834-B0BAC044B8A2', '0D692CF9-D183-456D-AB67-BB64D8714B77', null, null, '80');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1615, 'DBED3E9D-1738-4E88-99A6-BB16BFEA63FA', 'FDD7B9E0-B9DD-4161-ACE1-BF03D1369D1A', null, null, '3');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1616, 'A5EEFCF3-8849-4086-BFA1-B014BDA04647', '1397FAAD-4681-4D5F-8D4C-9F535594ECCA', null, null, '60');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1617, '95F5EEA0-A73B-4FA4-A3DA-B5F92B5E5E21', 'E8B5D4E8-7A37-4268-BF85-82A78FB6AA86', null, null, '70');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1618, '37B3F714-DB11-44E4-8832-A1967798AEB1', '9B1D30C2-A7F9-4360-B3B4-AAED7FFFF2E7', null, null, '80');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1619, 'BEBC2B49-7276-4534-9D1E-A580B525DA39', 'A380298A-727D-4B7E-B37A-BFF86423D989', null, null, '3');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1620, 'EB99D7BA-3431-481D-A9BE-9911F5702D58', '41608722-A35F-478E-9A3E-86669874A3C7', null, null, '60');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1621, '17B57B9B-997C-41C1-BBBA-AF29E99EEAD0', '506EC758-1846-423E-A05D-BC67D4310B89', null, null, '70');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1622, 'D914EE8F-4509-471A-AD48-A97C46D4D4DA', '176FCF50-2C80-481B-BDC3-A821E430CCFF', null, null, '80');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1623, 'CF8249FF-CD43-47CF-ACD8-9D87B8C43AEC', '600E7A25-560D-40DA-946D-A15CDF585C41', null, null, '3');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1624, '148F7AAA-6ABB-4263-9016-B33312AC6144', '56B4526F-2FEE-424A-9078-979CA1F59E7C', null, null, '30');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1625, 'BE6CE5A1-309F-4EFC-ADE5-B175EBFC62CA', 'EA32536C-B6F1-417F-8846-8230CBF44443', null, null, '3600');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1626, 'AB436DA9-6AD8-4E7B-9815-B7048230A28F', 'BC7F5BDC-6E59-4E69-8940-A43490C35713', null, null, '600');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1627, '84D0D560-7509-46AD-9324-B284C64C143B', '04E02EC3-E50C-4D22-BB06-BFBDE33B6B8C', null, null, '2400');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1628, 'C58AB542-1189-4242-B285-AF2DED27CA33', '25883DE2-DBEC-4D62-841A-80BA2F7DC4DA', null, null, '1800');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1629, 'E0F8CCF4-B1F0-481E-81B6-B350E03884BA', 'B12F3D59-04BC-4A58-AC91-9A2A09CB56DB', null, null, '1200');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1566, '6440BCBC-DCDB-4671-86A5-A2989D837CA5', '823267F3-E4B4-42C1-8A6A-AB9ED7671711', 'CF081C1F-D2ED-4575-9F72-A2237F5820A6', null, 'false');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1608, '70658097-2CE1-432D-8AFE-987AD88C8285', '5CDEB723-C229-47F0-87E4-AB5B0344CA4F', null, null, '60');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1805, '323544ec-d762-41e2-8ebb-b311283b0067', '9bbfb49d-d65b-4232-8e7b-1acbada7497f', '9e968ebc-e721-47fa-8193-4dcd7617752e', '如果设置为false，将不能使用邮箱进行登陆。', 'true');
INSERT INTO DCC_CONFIG_VALUE (ID, GUID, DEFINITIONGUID, OPTIONGUID, REMARK, K_VALUE) VALUES (1806, '06937aa7-4ab9-41c3-ac61-97477c5ebfb9', 'd15d5f0a-ce36-4f71-97b8-21e6f20a2509', 'e2c96d34-cdd4-4080-ad8d-aef4fc7a34fb', '如果设置为false，将不能使用工号进行登陆。', 'true');
create table DCC_DATA_NOTIFICATION
(
    ID             integer        not null
        primary key,
    GUID           varchar(38) not null
        constraint UK_OD7LX47CCDPOM85G963BMWBRF
            unique,
    CREATEDTIME    TIMESTAMP(6),
    OPERATIONTYPE  integer,
    EVENTTEXT      text,
    NOTIFIABLENAME varchar(255),
    FAILCOUNT      integer
);


create table DCC_DICTIONARY_TYPE
(
    ID     integer  not null
        primary key,
    K_NAME varchar(255),
    K_TYPE varchar(8) not null
        unique
);

comment on column DCC_DICTIONARY_TYPE.K_NAME is '描述数据字典类型表中类型的名称';

comment on column DCC_DICTIONARY_TYPE.K_TYPE is '数据字典类型代码';

INSERT INTO DCC_DICTIONARY_TYPE (ID, K_NAME, K_TYPE) VALUES (1, '身份级别', '1');
INSERT INTO DCC_DICTIONARY_TYPE (ID, K_NAME, K_TYPE) VALUES (2, '域', '2');
INSERT INTO DCC_DICTIONARY_TYPE (ID, K_NAME, K_TYPE) VALUES (3, '机构', '3');
INSERT INTO DCC_DICTIONARY_TYPE (ID, K_NAME, K_TYPE) VALUES (4, '用户', '4');
INSERT INTO DCC_DICTIONARY_TYPE (ID, K_NAME, K_TYPE) VALUES (6, '角色', '6');
INSERT INTO DCC_DICTIONARY_TYPE (ID, K_NAME, K_TYPE) VALUES (7, '应用', '7');
INSERT INTO DCC_DICTIONARY_TYPE (ID, K_NAME, K_TYPE) VALUES (1794, '单位二级类型', '8');
create table DCC_DICTIONARY
(
    ID             integer          not null
        primary key,
    GUID           varchar(38),
    PARENTGUID     varchar(32),
    DICTIONARYTYPE varchar(8)         not null
        constraint FK_DCC_DICTIONA_DCC_DICTION_01
            references DCC_DICTIONARY_TYPE (K_TYPE)
            on delete cascade,
    MARK           varchar(255),
    K_NAME         varchar(255)       not null,
    REALMGUID      varchar(38),
    ISDEFAULT      boolean default false not null,
    SORTNO         integer
);

comment on column DCC_DICTIONARY.DICTIONARYTYPE is '数据字典类型;';

comment on column DCC_DICTIONARY.MARK is '字典项代码';

comment on column DCC_DICTIONARY.K_NAME is '名字，或者实际意义项';

create index IXFK_DCC_DICTIONA_DCC_DIC01
    on DCC_DICTIONARY (DICTIONARYTYPE);

INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (1, '4A1AB317-B2EC-442E-A895-96F694CD15BC', null, '1', '1', '正局级', null, false, 0);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (2, '37DF448E-D8A8-4F47-B344-80A86B5533B7', null, '1', '2', '副局级', null, false, 100);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (3, 'DF11EC4F-1A21-46F8-B974-92B30E5D9F55', null, '1', '3', '正处级', null, false, 200);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (4, 'BA3625CE-C633-4A7D-B575-9AD4736B3187', null, '1', '4', '副处级', null, false, 300);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (5, '322650D7-F4E6-4663-8C04-89D1866F3334', null, '1', '5', '正科级', null, false, 400);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (6, '5AF1F148-6096-49A7-BF3E-9B83C92CA96E', null, '1', '6', '副科级', null, false, 500);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (7, 'B5CD70CC-3865-4A2F-A106-839AFC6686BA', null, '1', '7', '科员', null, false, 600);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (8, '32053C99-455F-4E21-8423-8A0DCDF49F79', null, '1', '8', '办事员', null, true, 700);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (9, '0186D043-6328-4B7F-AD9F-9F17ED81ADDA', null, '2', 'name', '域名', null, false, 0);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (10, 'EC0B5937-CC42-4795-B41C-BFEA562DAE4B', null, '2', 'sortNo', '排序号', null, false, 1);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (11, '2677DDBD-3747-43C2-A72B-A945FB79CA15', null, '3', 'fullName', '机构全称', null, false, 1);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (12, '2F92C9AE-237A-4FF1-B061-BD7FB1576972', null, '3', 'shortName', '机构简称', null, false, 2);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (13, '413D35AB-8FC1-463C-B1E9-AA814D427DD6', null, '3', 'orgCode', '机构代码', null, false, 3);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (14, 'BDE0B87C-F595-42A0-AB6B-9CA971849D13', null, '3', 'sortNo', '排序号', null, false, 6);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (15, '83369B82-072C-4D41-BC9C-8E88620A3B0D', null, '4', 'userName', '姓名', null, false, 1);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (16, '65AC55F0-EEC7-4B2F-95E3-8D7F9B89A80B', null, '4', 'loginName', '登录名', null, false, 2);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (17, '7EDDC815-7689-4795-A8DD-BF940559E5F5', null, '4', 'telephone', '固定电话', null, false, 3);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (18, '81EF81D9-8769-45D4-9C9D-BBE8A8FB35E6', null, '4', 'mobilephone', '手机', null, false, 4);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (19, '9FC4274E-7C6F-48C9-844E-AFF29D9EAA15', null, '4', 'email', '电子邮件', null, false, 5);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (20, 'A4C24D65-7F0E-4345-9304-8F00230CAD6B', null, '4', 'postcode', '邮编', null, false, 6);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (21, 'A53A21A9-613D-4E69-BEE3-BFB31BA7F884', null, '4', 'jobNumber', '工号', null, false, 7);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (22, 'E5177AD2-85BA-47C0-8C63-9C4FA1C8FC10', null, '4', 'sortNo', '显示顺序', null, false, 8);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (23, 'F990985C-4E76-45C5-98B1-ADFEC8670C4B', null, '6', 'roleName', '角色名称', null, false, 1);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (24, 'C20F66A8-5F0D-4DB9-9B3E-A09DBC9DED43', null, '6', 'sortNo', '显示顺序', null, false, 2);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (25, '132D9B9A-D955-474B-8D70-B1C98347E65E', null, '6', 'remark', '备注', null, false, 3);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (26, '912642AE-6C26-4FA1-A202-ABDA9291D861', null, '7', 'name', '应用名称', null, false, 1);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (27, '67DF86FD-D787-4709-B7FB-97A0E255048A', null, '7', 'remark', '备注', null, false, 2);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (28, '0B320BA2-1560-44D5-8EA5-B3BCB51780D2', null, '7', 'sortNo', '显示顺序', null, false, 3);
INSERT INTO DCC_DICTIONARY (ID, GUID, PARENTGUID, DICTIONARYTYPE, MARK, K_NAME, REALMGUID, ISDEFAULT, SORTNO) VALUES (1668, '5565257A-94D5-4E11-8D16-9DECDA7F8652', null, '4', 'remark', '备注', null, false, 9);
create table DCC_EXTENDED_INFO
(
    ID              integer   not null
        constraint "PK_ExtendedInfo"
            primary key,
    GUID            varchar(38) not null
        constraint UNIQUE_KEY_GUID
            unique,
    SUBJECTIDENTITY varchar(38) not null,
    FIELDNAME       varchar(50) not null,
    STRVALUE        varchar(255) default null,
    NUMBERVALUE     bigint     default NULL,
    DATEVALUE       TIMESTAMP(6)  default NULL,
    CLOBVALUE       text          default NULL,
    BOOLEANVALUE    boolean     default NULL
);

comment on table DCC_EXTENDED_INFO is '扩展信息表';

create index IX_EXTENDED_INFO_SUBJECT_FIELD
    on DCC_EXTENDED_INFO (SUBJECTIDENTITY, FIELDNAME);


create table DCC_FIELD_VALIDATE_DEFINITION
(
    ID           integer        not null
        primary key,
    GUID         varchar(38) not null
        constraint UK_WLLBVIMDT1QNL5YFUTOGH12N
            unique,
    ENTITYNAME   varchar(255),
    FIELDNAME    varchar(255),
    MAXLENGTH    integer,
    K_MAXVALUE   integer,
    MINLENGTH    integer,
    K_MINVALUE   integer,
    NULLABLE     boolean,
    REGEXPATTERN varchar(255)
);

INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1000, '9FD1C529E56A488CBD08C4972AB0CDF3', '用户', 'email', 100, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1001, '6C31948109C24EB488ABACAD0557090D', '用户', 'iconUrl', 255, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1002, '3BAD7B0EB2FE4C1D925ADE6E061CC565', '用户', 'loginName', 32, null, 4, null, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1003, '65DB36ED29AA4412AC2F51E47EF42147', '用户', 'loginPwd', 64, null, 4, null, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1004, 'C25BCD6D8EC54B48932D895BC01A40E1', '用户', 'mobilephone', 50, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1005, '2CC11080841B4A63A8B618BD5136A6B8', '用户', 'postcode', 20, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1006, '8955D14CF28C40A684F550E4303AD4DA', '用户', 'py', 50, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1007, '499C1A40B86D49D89A7D35D5ACD8B97E', '用户', 'remark', 200, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1008, 'E3DDE55A0E3E4D34942BD9CD57FAD26D', '用户', 'signPwd', 64, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1009, 'CE729212821542B9904DA673E4F353D7', '用户', 'state', 1, 3, 1, 1, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1010, '33E4C84137A4496C8677D0798C6F1F35', '用户', 'telephone', 50, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1011, '72FBF25774764EDD82246568FDBC7C74', '用户', 'userName', 50, null, 2, null, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1012, '933812765942441086A3ED7E911665CD', '用户', 'userType', 0, 2, 0, 1, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1013, '8482F4356CCB43738355B59315FE7209', '角色', 'roleType', 100, 4, 0, 0, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1014, 'DA9A729D863F4A559E48CF12FA6D7AD6', '角色', 'roleName', 50, null, 2, null, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1015, '3FDE93E8BEC942CFB9C74DADE9FDD7CF', '角色', 'remark', 200, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1016, 'CE8192B4CADC496CAE55213D4ED1E14B', '机构', 'fullName', 50, 4, 0, 0, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1017, '064EA7B331A7447B9937E74762EC991B', '机构', 'orgType', 0, 3, 0, 1, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1018, '35A7D0475BEA4F4480829BA41127A6AD', '机构', 'py', 50, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1019, 'C7B45DDA12E942EBA6F4C8B0F902DCF2', '机构', 'remark', 200, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1020, '768202D24F4E49B19905AF1A198A1C74', '机构', 'responsibility', 200, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1021, '9715FAB93EDC4DA29C4291F038E94B2B', '机构', 'shortName', 50, null, 2, null, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1022, '3F6A4CF49C0346D7929EDD0EAFFC66D3', '机构', 'state', null, 1, null, 0, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1023, '6D7008C453A2467D9630C0C37ED71D63', '机构', 'supervisionTelephone', 15, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1024, '4B2CC05CDEC34233991EA3A71D04C075', '访问控制条目', 'subjectType', null, 2, null, 1, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1025, '373BA9ACC3A0456BA127EF2CD1F9B811', '访问控制条目', 'resourceType', null, 2, null, 1, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1026, '2927D958A7B748D8BE7EA4A42E8F45A7', '应用', 'name', 50, 4, 2, 0, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1027, '3361B4C4C2AA4C47A79FB4418AE6D29D', '应用', 'remark', 200, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1028, '125E9F51AF4D4415BD415064BCFEEF6E', '功能', 'name', 50, 4, 2, 0, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1029, 'E729C94DB0644414979C696581E47282', '功能', 'remark', 200, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1030, 'D580339DADB649A4ADF68C4AF33AD019', '功能', 'mutexType', null, 4, null, 0, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1031, '81DAF1FC9F42431D9398EEB5483F948A', '功能', 'internalType', null, 2, null, 1, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1032, 'CD0A961ADCDE41F4A5658EDC55F0D563', '域', 'name', 50, null, 2, null, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1033, '01F95ECA701A4DBE8F4F3EC78E9730E7', '安全配置值', 'value', 200, null, 1, null, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1034, 'DD994DB25C3D4697BAF6056B85140C17', '同步应用', 'name', 50, null, 2, null, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1035, '9A2187C1E8FE400F9F20EB94BB4B6FDF', '同步应用', 'syncDataAccessType', null, 3, null, 1, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1036, 'E85E638007BE49BE90A8A70234F8BFAC', '同步任务', 'name', 50, null, 2, null, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1037, '909B2B90DD694958AF2F008BED3AE001', '同步任务', 'remark', 200, null, 0, null, true, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1038, 'FE238F46FBB04705A2259923F99D81A9', '同步任务', 'syncType', null, 2, null, 1, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1039, 'F6BAAF8C78C741DB8390F1A258969DCD', '同步任务', 'syncDirection', null, 3, null, 1, false, null);
INSERT INTO DCC_FIELD_VALIDATE_DEFINITION (ID, GUID, ENTITYNAME, FIELDNAME, MAXLENGTH, K_MAXVALUE, MINLENGTH, K_MINVALUE, NULLABLE, REGEXPATTERN) VALUES (1090, '221FAD82-98BC-43F1-8955-BCBB88AC43AF', '角色', 'realmGuid', 38, null, 1, null, false, null);
create table DCC_FUNCTION
(
    ID           integer           not null
        primary key,
    GUID         varchar(38)    not null
        constraint UK_64O23N9DIUSYWKWIKTO2T9ANY
            unique,
    APPGUID      varchar(38),
    INTERNALTYPE integer,
    K_NAME       varchar(190),
    PARENTGUID   varchar(38),
    PRIORITY     integer,
    REMARK       varchar(255),
    RESOURCETYPE integer,
    SORTNO       integer           not null,
    TREECODE     varchar(190)
        unique,
    URL          varchar(255),
    MUTEXTYPE    integer default 0 not null,
    NEEDLOG      boolean  default false not null,
    READONLY     boolean default true
);

INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1147, '5667ABEB-0AD2-E69F-E050-E050A8C00301', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '审计报表下载', 'BE2E43A2-F7A1-482E-9071-999E84B510D3', 0, null, 1, 3300, '032003', 'buz/auditMnt/auditReport.html', 3, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1148, 'AB871E14-652C-469B-BA16-B586B09188C6', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '个人信息', '3ec3c941-e2fb-4acd-b03a-bb3887635a7e', 1, null, 1, 5100, '001002', 'buz/user/infoMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1149, 'B37327C9-FD09-4091-B152-830CC919E0A8', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '设置密码', 'F1703306-D10E-4D72-A45C-56026702EAFB', 1, null, 1, 5000, '028003002', 'buz/userMnt/pwdSet.html', 1, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1150, 'E916A191-363F-409F-BA8B-4F2A661481FA', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '用户实际权限查询', '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', 1, null, 1, 5000, '029009', 'buz/userMnt/userAuthView.html', 2, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1151, '568cb299-39ea-401f-8146-547e46f3cbd8', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '职位管理', '69F8B25B-0F3E-4D98-987E-4C6B08F952E7', 0, null, 1, 2050, '029011', 'buz/roleMnt/postMnt.html', 1, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1152, '3ec3c941-e2fb-4acd-b03a-bb3887635a7e', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '个人管理', null, 1, null, 1, 5000, '001', null, 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1153, '9464daaf-9415-4b5a-bdb3-2614bf2d88bb', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '个人代理设置', '3ec3c941-e2fb-4acd-b03a-bb3887635a7e', 1, null, 1, 5200, '001001', 'buz/user/agentMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1154, 'bac50593-8dea-471c-b0fd-c8718d5debe8', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '新增域', 'E2701565-A228-42EE-9872-35353E90244B', null, null, null, 1000, '028001001', 'POST /realms/add', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1155, '632648bf-74d2-4df1-ab0e-d5bc83e5a66d', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改域', 'E2701565-A228-42EE-9872-35353E90244B', null, null, null, 2000, '028001002', 'POST /realms/modify', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1156, '03ea9dd8-fab6-41b3-9bf7-bc70e582a743', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除域', 'E2701565-A228-42EE-9872-35353E90244B', null, null, null, 3000, '028001003', 'POST /realms/delete', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1157, '33cc45dd-51fe-4d28-8f8d-a3122dbabdc2', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '新增域管理员', 'E2701565-A228-42EE-9872-35353E90244B', 0, null, 0, 1000, '028005001', 'POST /realmManagers/add', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1158, 'f8ec5be7-affd-4aa8-bf74-3c473bf942ef', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '移除域管理员', 'E2701565-A228-42EE-9872-35353E90244B', 0, null, 0, 2000, '028005002', 'POST /realmManagers/delete', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1560, '260092A8-282C-4B91-AAC8-BFF5CA953EF7', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '系统维护', null, null, '系统维护', 1, 10000, '034', null, 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1574, 'F45A1C76-8BEB-4F33-A86E-A0C1B6A001F0', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '已登录用户管理', '260092A8-282C-4B91-AAC8-BFF5CA953EF7', null, '已登录用户管理', null, 9999, '034003', 'buz/userMnt/loginUserMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1634, '75B837C7-FB40-79CC-E053-E053B80E1FAC', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '预警通知管理', '260092A8-282C-4B91-AAC8-BFF5CA953EF7', null, '预警通知管理', null, 9999, '034001', 'buz/noticeMnt/noticeMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1637, 'e2e65ed8-72dd-4b20-8209-5647d0686d37', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '健康监控', '260092A8-282C-4B91-AAC8-BFF5CA953EF7', null, '健康监控', null, 9999, '034002', 'buz/healthMnt/serverMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1159, '1b1253af-3c57-4318-ab57-6d0c12906c27', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '新增机构', '49DC9281-E1A9-43E7-AC94-10CBD3FF2DE0', 0, null, 0, 1000, '028002001', 'POST /realmOrgs/addOrgOfRealm', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1160, 'ee706728-edc7-497f-8a28-30265c680fba', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '撤销机构', '49DC9281-E1A9-43E7-AC94-10CBD3FF2DE0', 0, null, 0, 4000, '028002002', 'POST /orgs/delete', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1161, '4e1cdf75-f333-40a7-b2b2-65c95ce4bbe6', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '新增部门', '49DC9281-E1A9-43E7-AC94-10CBD3FF2DE0', null, null, null, 2000, '028002003', 'POST /orgs', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1162, 'fcde4eb5-e39c-4fc4-bcfa-12182e702355', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改机构', '49DC9281-E1A9-43E7-AC94-10CBD3FF2DE0', null, null, null, 3000, '028002004', 'POST /orgs/modify', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1163, 'b10688c5-12a7-47cc-bd2d-85fa0dda8bb0', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '新增用户', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 1000, '028003003', 'POST /realmUsers/addUser', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1164, '72c6e3cb-bd7c-4cbe-b603-7128102b0609', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改用户信息', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 2000, '028003004', 'POST /users/modify', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1165, 'd5809727-f108-41ae-894c-66658d6eb7fb', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '设置用户离岗', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 3000, '028003005', 'POST /users/delete', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1166, 'd7dc85a2-34da-42ab-b2e5-31e6edb82e5f', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '管理员重设密码', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 4000, '028003001', 'POST /users/changePwd', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1167, 'bd0f4a52-805a-41b5-99ed-a62ce922fb42', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加用户到机构', 'D4597E98-305C-42C8-AD88-7BB81B99C1CC', null, null, null, 1000, '028004001', 'POST /orgUsers/add', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1168, '51b1d949-dae7-4fea-8a49-549fa7aca658', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '将用户从机构中删除', 'D4597E98-305C-42C8-AD88-7BB81B99C1CC', null, null, null, 2000, '028004002', 'POST /orgUsers/delete', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1169, '80a3f1e8-d48c-4bd5-9ffc-7690bf276eb5', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改用户岗位', 'D4597E98-305C-42C8-AD88-7BB81B99C1CC', null, null, null, 3000, '028004003', 'POST /orgUsers/modify', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1170, '7221a67b-e8c5-4612-80da-e42f7ff119a0', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '新增角色', 'CD5EABD5-50BA-470D-A075-94CDD29710D0', 0, null, 0, 1000, '029001001', 'POST /realmRoles/addGeneralRole', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1171, '86c0d1ae-2936-43bb-8fc0-cae5c8b7c849', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改角色', 'CD5EABD5-50BA-470D-A075-94CDD29710D0', 0, null, 0, 2000, '029001002', 'POST /roles/modifyGeneralRole', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1172, '593776a1-17d7-4915-9d27-761e9747a42d', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除角色', 'CD5EABD5-50BA-470D-A075-94CDD29710D0', 0, null, 0, 3000, '029001003', 'POST /roles/deleteGeneralRole', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1173, '112ba525-c0b6-45c5-b9b8-cf3200d20012', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加系统角色成员用户', '217C6E9E-2FB3-4386-A05D-1A97ACF878AF', 0, null, 0, 1000, '029002001', 'POST /roleMembers/addSysUserMembers', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1174, '49771b10-a421-4ea6-a810-7cdcd851babd', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加系统角色所属角色', '217C6E9E-2FB3-4386-A05D-1A97ACF878AF', null, null, null, 3000, '029002002', 'POST /roleMembers/addBelongingRoles', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1175, '9d304881-3fc3-4881-8c52-ef6aea72059e', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '新增应用', 'EAB8A05E-ACAA-4973-B077-F034E2E09707', 0, null, 0, 1000, '029005001', 'POST /apps/add', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1176, 'e6c0e428-5ebd-4d62-8a6c-066e757c444a', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改应用', 'EAB8A05E-ACAA-4973-B077-F034E2E09707', 0, null, 0, 2000, '029005002', 'POST /apps/modify', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1364, '1727C460-021B-4697-AD16-8D6C9F65B1E0', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '登录验证码禁用管理', '69F8B25B-0F3E-4D98-987E-4C6B08F952E7', 0, '添加登录不发验证码的人', 0, 2070, '028007', 'buz/userMnt/notSendAuthcodeUserMnt.html', 2, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1365, '26DE3567-85FD-4E49-A9F4-8FE42B92810D', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除禁用登录验证码用户', '1727C460-021B-4697-AD16-8D6C9F65B1E0', 0, '删除', 0, 2071, '028007001', 'POST /users/enableAuthCode', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1366, '4CAC47A7-13ED-417C-8C6B-873513F99A7E', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '增加禁用登录验证码用户', '1727C460-021B-4697-AD16-8D6C9F65B1E0', 0, '添加', 0, 2072, '028007002', 'POST /users/disableAuthCode', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1796, 'e8819ac8-6f00-4a9a-bc09-19921990d7dc', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '为多个角色设置一项权限', 'C7AE9333-ED9F-4A24-837E-0600967C1D07', null, null, null, 4000, null, 'POST /ace/authorizeResourceToRoles', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1797, 'af8829ec-9820-4b2f-ace7-7b1628a2686e', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '为多个用户设置一项权限', 'C7AE9333-ED9F-4A24-837E-0600967C1D07', null, null, null, 5000, null, 'POST /ace/authorizeResourceToUsers', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1120, 'e0aa298c-6d3f-42af-91e6-943b8099d6b0', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '快捷功能管理', '3ec3c941-e2fb-4acd-b03a-bb3887635a7e', null, null, null, 9999, null, 'buz/user/userShortcut.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1119, '245633d5-f7cb-4a87-b24a-5913f7eb240d', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '快捷功能', null, null, '快捷功能管理', 1, 500, null, null, 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1118, 'a49911ad-3fc5-43c2-9dd8-0c6aa44925cc', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除快捷功能', 'e0aa298c-6d3f-42af-91e6-943b8099d6b0', null, null, 1, 9999, null, 'POST /u/shortcutDelete', 0, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1117, 'ec3f0f71-dc85-43c4-adaf-91faf7279806', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改快捷功能', 'e0aa298c-6d3f-42af-91e6-943b8099d6b0', null, null, 1, 9999, null, 'POST /u/shortcutModify', 0, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1116, 'fcd782f3-967c-4385-ae6c-8737dd6513ac', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加快捷功能', 'e0aa298c-6d3f-42af-91e6-943b8099d6b0', null, null, null, 9999, null, 'POST u/shortcutAdd', 0, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1129, 'C7AE9333-ED9F-4A24-837E-0600967C1D07', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '应用功能管理', '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', 1, null, 1, 2600, '029006', 'buz/functionMnt/functionMnt.html', 2, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1130, 'EAB8A05E-ACAA-4973-B077-F034E2E09707', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '应用管理', '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', 0, null, 1, 2500, '029005', 'buz/appMnt/appMnt.html', 1, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1132, '9EF3B0DD-7E7C-4067-BAFE-C7382208F98A', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '岗位角色成员管理', '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', 1, null, 1, 2300, '029003', 'buz/roleMnt/roleMemberSetterStation.html', 2, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1133, '217C6E9E-2FB3-4386-A05D-1A97ACF878AF', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '系统角色成员管理', '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', 1, null, 1, 2200, '029002', 'buz/roleMnt/roleMemberSetterSystem.html', 2, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1134, 'CD5EABD5-50BA-470D-A075-94CDD29710D0', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '角色管理', '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', 1, null, 1, 2100, '029001', 'buz/roleMnt/roleMnt.html', 1, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1135, '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '统一权限管理', null, 1, null, 1, 2000, '029', null, 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1136, 'D4597E98-305C-42C8-AD88-7BB81B99C1CC', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '机构用户管理', '69F8B25B-0F3E-4D98-987E-4C6B08F952E7', 1, null, 1, 1400, '028004', 'buz/stationMnt/stationMnt.html', 1, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1137, 'F1703306-D10E-4D72-A45C-56026702EAFB', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '用户管理', '69F8B25B-0F3E-4D98-987E-4C6B08F952E7', 1, null, 1, 1300, '028003', 'buz/userMnt/userMnt.html', 1, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1138, '49DC9281-E1A9-43E7-AC94-10CBD3FF2DE0', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '机构管理', '69F8B25B-0F3E-4D98-987E-4C6B08F952E7', 1, null, 1, 1200, '028002', 'buz/orgMnt/orgMnt.html', 1, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1139, 'E2701565-A228-42EE-9872-35353E90244B', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '域管理', '69F8B25B-0F3E-4D98-987E-4C6B08F952E7', 1, null, 1, 1100, '028001', 'buz/realmMnt/realmMnt.html', 1, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1140, '69F8B25B-0F3E-4D98-987E-4C6B08F952E7', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '统一用户管理', null, 1, null, 1, 1000, '028', null, 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1142, 'BE2E43A2-F7A1-482E-9071-999E84B510D3', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '统一审计管理', null, 0, null, 1, 3000, '032', null, 3, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1121, '7DFD03C9-853E-4096-ACF7-A9241A3FC5D5', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '定时任务管理', '4FAC7F8A-7745-413F-B1E5-C20A548691B7', 1, null, 1, 4500, '011001005', 'buz/scheduleMnt/scheduleMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1122, 'F537B4D9-211C-4690-BC44-C8F5ED2D2737', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '详细日志管理', '4FAC7F8A-7745-413F-B1E5-C20A548691B7', 1, null, 1, 4400, '011001004', 'buz/ldapSync/syncLogDetailMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1143, '9272132D-D2CB-4DB9-A842-962673F55E9C', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '审计日志查询', 'BE2E43A2-F7A1-482E-9071-999E84B510D3', 0, null, 1, 3100, '032001', 'buz/auditMnt/auditMnt.html', 3, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1144, '02AA513B-3A10-4A58-9F45-9EFBAD093755', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '审计日志统计', 'BE2E43A2-F7A1-482E-9071-999E84B510D3', 0, null, 1, 3200, '032002', 'buz/auditMnt/auditStatistics.html', 3, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1640, '629693E5-9BD3-40EA-8B32-9346F3B396D4', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '个人秘钥管理', '3ec3c941-e2fb-4acd-b03a-bb3887635a7e', null, null, null, 9999, '001003', 'buz/user/secretMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1643, 'd8279286-47d7-4c06-a60a-960179314800', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '恢复机构', '49DC9281-E1A9-43E7-AC94-10CBD3FF2DE0', null, null, null, 6000, '028002006', 'POST /orgs/recover', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1644, '4cb9ca43-a27b-449d-9880-505b4036e991', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '挂起机构', '49DC9281-E1A9-43E7-AC94-10CBD3FF2DE0', null, null, null, 5000, '028002005', 'POST /orgs/hangup', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1645, '8478ef47-8f2f-4d07-9e14-e9dd15d0d86b', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '上移机构', '49DC9281-E1A9-43E7-AC94-10CBD3FF2DE0', null, null, null, 9997, '028002007', 'POST /orgs/changeSortUp', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1646, '2d5201a4-9722-4de8-9f9c-fcf53e605856', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '下移机构', '49DC9281-E1A9-43E7-AC94-10CBD3FF2DE0', null, null, null, 9998, '028002008', 'POST /orgs/changeSortDown', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1651, '88da4e07-1225-4e1f-a353-e5eb1ed8814e', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '用户挂起', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 4500, '028003015', 'POST /users/hangup', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1653, '17b3303c-7ca9-46c5-aa09-1be77caf652a', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '用户搜索', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 9999, '028003019', 'GET /users/searchByState', 1, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1655, 'e08a571d-9472-4ebf-8c9d-0aa322605c88', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改个人信息', 'AB871E14-652C-469B-BA16-B586B09188C6', null, null, null, 9999, '001002001', 'POST /u/modify', 0, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1656, '160b3233-5528-491a-b4e4-f20a7f211d74', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '查询审计日志', '9272132D-D2CB-4DB9-A842-962673F55E9C', null, '查询审计日志', null, 9999, '032001001', 'GET /audit/logs/search', 3, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1657, 'a26a5caf-1b3b-4780-8f96-cd2853ccbfc9', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '下载审计日志', '9272132D-D2CB-4DB9-A842-962673F55E9C', null, '下载审计日志', null, 9999, '032001002', 'GET /audit/logs/prepareDownload', 3, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1658, 'e0bd7983-9c88-482c-8179-989f252fc8c9', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加用户代理人', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 9999, '028003016', 'POST /users/addUserAgents', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1659, '9c02fbd8-d95e-42c6-9925-edf8013f162d', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除用户代理人', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 9999, '028003018', 'POST /u/deleteAgents', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1660, '6a524b44-ef76-4193-848d-0220a3bb9ff8', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改个人密码', 'AB871E14-652C-469B-BA16-B586B09188C6', null, null, null, 9999, '001002002', 'POST /u/changePwd', 0, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1661, '739eaa68-b4bb-4cd5-8558-b24456dd96ac', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '个人添加代理人', '9464daaf-9415-4b5a-bdb3-2614bf2d88bb', null, null, null, 9999, '001001001', 'POST /u/addAgent', 0, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1662, 'b319461f-7206-4122-b635-3ec1972ddabb', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除代理人', '9464daaf-9415-4b5a-bdb3-2614bf2d88bb', null, null, null, 9999, '001001002', 'POST /u/deleteAgents', 0, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1376, 'fa4f664f-8892-48a6-adfb-a81217271d57', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '数据导入', '260092A8-282C-4B91-AAC8-BFF5CA953EF7', null, null, null, 6500, '034004', 'buz/importExport/importExport-tpl.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1177, '108f1c67-ac1b-4b62-9c88-bac470d6af42', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除应用', 'EAB8A05E-ACAA-4973-B077-F034E2E09707', null, null, null, 3000, '029005003', 'POST /apps/delete', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1178, '9d147bc0-a473-4b83-9f90-4dee0794ab92', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加应用管理员', 'EAB8A05E-ACAA-4973-B077-F034E2E09707', null, null, null, 4000, '029010001', 'POST /appManagers/add', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1179, 'd91123e8-2757-40e7-8735-d69eb62e4d36', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '取消应用管理员', 'EAB8A05E-ACAA-4973-B077-F034E2E09707', 0, null, 0, 5000, '029010002', 'POST /appManagers/delete', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1180, 'b7bcc7f1-12aa-4323-9ce9-0074150abee2', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加功能', 'C7AE9333-ED9F-4A24-837E-0600967C1D07', null, null, null, 1000, '029006001', 'POST /functions/add', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1181, '8e3a8027-e0f0-4e44-9fa5-e6a1c5611781', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改功能', 'C7AE9333-ED9F-4A24-837E-0600967C1D07', null, null, null, 2000, '029006002', 'POST /functions/modify', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1182, '0162c5d6-0d60-46fd-b800-dfafb5452e84', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除功能', 'C7AE9333-ED9F-4A24-837E-0600967C1D07', null, null, null, 3000, '029006003', 'POST /functions/delete', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1183, 'b4103fe8-a7be-4655-a965-da1a6386f47d', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '为一个角色设置多项权限', 'EC4258B6-96B1-4FEA-83FE-4282752461FA', null, '授权取消授权都是这个功能', null, 1000, '029007001', 'POST /ace/authorizeResourcesToRole', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1261, 'ffbc5b6f-2310-4217-b9c9-90d57021004b', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加岗位角色成员角色', '9EF3B0DD-7E7C-4067-BAFE-C7382208F98A', null, null, null, 130, '029003004', 'POST /roleMembers/addStationRoleMembers', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1262, '92ddf0be-17a8-47d1-9234-f1446fe2f7c8', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除岗位角色成员用户', '9EF3B0DD-7E7C-4067-BAFE-C7382208F98A', null, null, null, 125, '029003002', 'POST /roleMembers/deleteStationUser', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1263, 'be974498-426e-4f43-9e03-2842b5932cb2', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加岗位角色成员用户', '9EF3B0DD-7E7C-4067-BAFE-C7382208F98A', 0, null, 0, 123, '029003003', 'POST /roleMembers/addStationUser', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1264, '9ec19092-edda-4ecc-8bf6-35f51ef69d53', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除系统角色所属角色', '217C6E9E-2FB3-4386-A05D-1A97ACF878AF', 0, null, 0, 9999, '029002012', 'POST /roleMembers/deleteBelongingRoles', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1265, '8d2a0a97-2abe-4d3e-a823-425631d29f3e', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除系统角色成员角色', '217C6E9E-2FB3-4386-A05D-1A97ACF878AF', null, null, null, 9999, '029002009', 'POST /roleMembers/deleteSysRoleMembers', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1266, 'd3741ea4-6b35-4074-aa55-66c11bc934c6', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除系统角色用户成员', '217C6E9E-2FB3-4386-A05D-1A97ACF878AF', null, null, null, 9999, '029002008', 'POST /roleMembers/deleteSysUserMembers', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1267, '1d216951-e682-4652-a4ae-c5272322e551', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加系统角色成员角色', '217C6E9E-2FB3-4386-A05D-1A97ACF878AF', null, null, null, 2000, '029002006', 'POST /roleMembers/addSysRoleMembers', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1268, 'c32d3b42-4d35-4568-af02-2a60d2964dc7', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除职位', '568cb299-39ea-401f-8146-547e46f3cbd8', 0, null, 0, 2053, '029011011', 'POST /roles/deletePost', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1269, 'bb8b3b1c-35b1-49ba-b3b0-b7688e5b9ca5', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改职位', '568cb299-39ea-401f-8146-547e46f3cbd8', 0, null, 0, 2052, '029011010', 'POST /roles/modifyPost', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1270, '393c3c0d-5516-494a-af38-5df6a3f6217c', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '新增职位', '568cb299-39ea-401f-8146-547e46f3cbd8', 0, '新增职位', 0, 2051, '029011009', 'POST /realmRoles/addPostRole', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1271, '49b9e03d-febc-4137-861d-d44bef494d10', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '职位人员删除', '568cb299-39ea-401f-8146-547e46f3cbd8', 0, '删除职位人员', 0, 2055, '029011015', 'POST /roleMembers/deletePostMembers', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1272, '1ba39fa2-2c0c-4006-b8fd-8561d8751f23', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '增加职位人员', '568cb299-39ea-401f-8146-547e46f3cbd8', 0, '为职位添加人员', 0, 2054, '029011014', 'POST /roleMembers/addPostMembers', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1274, 'dd3b9acc-5432-4b9c-8b03-00bfe3bbbb4a', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '用户权限来源', '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', null, '用户权限来源', null, 2900, '029012', 'buz/userMnt/userAuthSrc.html', 2, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1259, 'df1dced2-5c5b-4bfd-adfd-129d02a496bc', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '解锁用户', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 9999, '028003011', 'POST /users/unlock', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1260, 'd0b41a25-65cf-44c4-bc89-b77939f4b797', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除岗位角色成员角色', '9EF3B0DD-7E7C-4067-BAFE-C7382208F98A', null, null, null, 135, '029003005', 'POST /roleMembers/deleteStationRoleMembers', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1275, 'f8b22880-b94c-418c-9127-43babbc0be40', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '用户恢复', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, '将已离职人员恢复为正常状态', null, 6000, '028003013', 'POST /users/recover', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1276, '82076303-d694-47e0-b23f-ac2a3df2750e', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '用户调离', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, '设置人员的域属性为空', null, 5000, '028003012', 'POST /users/transferOut', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1277, 'b5e69dea-b288-4efa-814c-ac1aaa4c5c74', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '调入', 'f9d4febf-140d-420f-8ee8-615811d0096a', null, null, null, 1410, '028006001', 'POST /users/transferIn', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1552, '43c242db-23d2-43fe-b8e4-6da6610ecd6e', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '设置安全策略', '4d82a534-a18c-467a-93de-ab02a6150ee5', null, '修改安全策略的配置', null, 1, '029014001', 'POST /configInstances', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1278, 'f9d4febf-140d-420f-8ee8-615811d0096a', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '用户调入', '69F8B25B-0F3E-4D98-987E-4C6B08F952E7', null, '人员跨域调入接口', null, 1400, '028006', 'buz/userMnt/transferMnt.html', 1, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1279, 'b96b4b09-f773-471b-83f8-16c4b3d261b3', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '为一个用户设置多项权限', 'BADF62F4-1FAB-4456-8CFB-1F1647C31D27', null, '设置用户的权限，授权和取消授权都是它', null, 2810, '029008001', 'POST /ace/authorizeResourcesToUser', 2, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (24340, '4d82a534-a18c-467a-93de-ab02a6150ee5', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '安全策略配置', '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', null, null, null, 6000, '029014', 'buz/config/securityStrategyMnt.html', 2, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1123, 'A690AAF5-E0D9-4F5E-8F20-976967D70CBA', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '汇总日志管理', '4FAC7F8A-7745-413F-B1E5-C20A548691B7', 1, null, 1, 4300, '011001003', 'buz/ldapSync/syncLogMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1124, 'F53B7513-3B2B-44A2-AEBB-C96E51354CE3', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '同步任务管理', '4FAC7F8A-7745-413F-B1E5-C20A548691B7', 1, null, 1, 4200, '011001002', 'buz/ldapSync/appTaskMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1125, '7E7D87D9-68E3-409A-9C86-20DBD31F85AA', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '同步应用管理', '4FAC7F8A-7745-413F-B1E5-C20A548691B7', 1, null, 1, 4100, '011001001', 'buz/ldapSync/appMnt.html', 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1126, '4FAC7F8A-7745-413F-B1E5-C20A548691B7', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '同步管理', '2530d0b6-a8f2-4923-9fd6-87482119de41', 1, null, 1, 4000, '011001', null, 0, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1127, 'BADF62F4-1FAB-4456-8CFB-1F1647C31D27', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '用户授权', '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', 0, null, 1, 2800, '029008', 'buz/userMnt/userAuthorize.html', 2, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1128, 'EC4258B6-96B1-4FEA-83FE-4282752461FA', '43972DD7-CF57-46AF-9D60-CED094C9E738', 1, '角色授权', '802F8954-0FF6-4FA7-8D1D-650C4C971DE7', 1, null, 1, 2700, '029007', 'buz/roleMnt/roleAuthorize.html', 2, true, true);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1780, '1bc3ebbc-3dc5-4468-bb01-a28070356ef9', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '个人新增秘钥', '629693E5-9BD3-40EA-8B32-9346F3B396D4', null, null, null, 1000, '001003003', 'POST /users/addUserSecretKeys', 0, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1781, 'c35ff2e9-e7d5-4c90-9160-c3700fa88325', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '个人修改秘钥', '629693E5-9BD3-40EA-8B32-9346F3B396D4', null, null, null, 2000, '001003004', 'POST /users/modifyUserSecretKeys', 0, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1782, '910f38e0-5bb0-4872-ac86-8a431b305133', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '个人删除秘钥', '629693E5-9BD3-40EA-8B32-9346F3B396D4', null, null, null, 3000, '001003005', 'POST /users/deleteUserSecretKeys', 0, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1783, '3683620d-48a9-40a7-a482-a979c98485bd', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '添加用户秘钥', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 8001, '028003021', 'POST /users/addUserSecretKeys', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1784, 'a19b6679-90ae-42cd-ab79-9b7e7f6d494e', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '删除用户秘钥', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 8003, '028003022', 'POST /users/deleteUserSecretKeys', 1, true, false);
INSERT INTO DCC_FUNCTION (ID, GUID, APPGUID, INTERNALTYPE, K_NAME, PARENTGUID, PRIORITY, REMARK, RESOURCETYPE, SORTNO, TREECODE, URL, MUTEXTYPE, NEEDLOG, READONLY) VALUES (1785, 'b887d6a9-5a7f-4ea7-a16e-761218838b18', '43972DD7-CF57-46AF-9D60-CED094C9E738', 2, '修改用户秘钥', 'F1703306-D10E-4D72-A45C-56026702EAFB', null, null, null, 8002, '028003023', 'POST /users/modifyUserSecretKeys', 1, true, false);
create table DCC_HEALTH_DEVICE
(
    ID          integer        not null
        primary key,
    GUID        varchar(38) not null
        constraint UK_6Q70FKVCW7WB3JBOSCXPHN654
            unique,
    ALIAS       varchar(255),
    K_DESC      varchar(255),
    DISABLED    boolean,
    INDEXNAMES  varchar(255),
    K_MAXVALUE  FLOAT,
    K_NAME      varchar(190),
    SERVERGUID  varchar(38),
    K_TYPE      integer        not null,
    HANDLEDATE  DATE       default NULL,
    HANDLELEVEL integer default NULL
);


create table DCC_HEALTH_DEVICE_STATUS
(
    ID               integer        not null
        primary key,
    GUID             varchar(38) not null
        constraint UK_QKL14C2HKNUG9TX0HHORHDIXH
            unique,
    DEVICEGUID       varchar(38),
    MAX              varchar(255),
    K_NAME           varchar(190),
    K_TYPE           integer,
    USAGE            varchar(255),
    USED             varchar(255),
    AVAILABLEVALUE   varchar(255),
    AVAILABLEPERCENT varchar(255)
);


create table DCC_HEALTH_SERVER
(
    ID             integer        not null
        primary key,
    GUID           varchar(38) not null
        constraint UK_NUV28ADC067UXKJ3Y8IHJAU0R
            unique,
    ALIAS          varchar(255),
    HANDLEDATE     DATE                default NULL,
    LASTREPORTTIME DATE                default NULL,
    NETWORKINFO    varchar(1024) default NULL
);


create table DCC_JOB
(
    ID          integer        not null
        primary key,
    GUID        varchar(38) not null
        constraint UK_QYLDT9JFQF5JL52RNYB8A41FK
            unique,
    ENABLED     boolean,
    LASTEXECUTE TIMESTAMP(6),
    METHOD      varchar(255),
    K_NAME      varchar(190),
    URL         varchar(255),
    TRIGGERNAME varchar(38)
);

create unique index DCC_JOB_INDEX_K_NAME_UINDEX
    on DCC_JOB (K_NAME);

INSERT INTO DCC_JOB (ID, GUID, ENABLED, LASTEXECUTE, METHOD, K_NAME, URL, TRIGGERNAME) VALUES (1371, 'd3391c41-0886-40be-b944-941723c5d601', true, TO_TIMESTAMP('2020-03-09 16:32:58.525000', 'YYYY-MM-DD HH24:MI:SS.FF6'), 'GET', '每天定时收集审计日志', '/audit/collect', '3dbd0158-d55e-4f16-8541-ce78b47e5152');
INSERT INTO DCC_JOB (ID, GUID, ENABLED, LASTEXECUTE, METHOD, K_NAME, URL, TRIGGERNAME) VALUES (1372, '079f6ae6-c1a8-4840-b418-17000574c6e8', true, TO_TIMESTAMP('2020-03-09 16:32:58.525000', 'YYYY-MM-DD HH24:MI:SS.FF6'), 'GET', '对审计日志进行归档处理', '/audit/archive', 'fef26ccd-704b-417d-b5c9-127d512619f6');
INSERT INTO DCC_JOB (ID, GUID, ENABLED, LASTEXECUTE, METHOD, K_NAME, URL, TRIGGERNAME) VALUES (1373, '1d7b6dfd-cc34-4799-b2b5-6b72fe752151', true, null, 'GET', '定时检查应用健康状况', '/h/check', '81232955-fb6e-4b08-b759-cd867412ac40');
create table DCC_LOGIN_USER
(
    ID             integer         not null
        constraint DCC_LOGIN_USER_KEY_ID
            primary key,
    GUID           varchar(38)  not null,
    LOGINNAME      varchar(64)  not null,
    K_NAME         varchar(64)  not null,
    AGENTGUID      varchar(38),
    AGENTLOGINNAME varchar(38),
    AGENTNAME      varchar(64),
    LOGINTIME      DATE               not null,
    REMOTEHOST     varchar(50)  not null,
    REMOTEIP       varchar(50)  not null,
    TICKET         varchar(128) not null
);

comment on table DCC_LOGIN_USER is '已登录用户';

create index DCC_LOGIN_USER_INDEX_LOGINTIME
    on DCC_LOGIN_USER (LOGINTIME desc);


create table DCC_NOTICE
(
    ID                  integer        not null
        primary key,
    GUID                varchar(38) not null
        constraint SYS_C0035244
            unique,
    NOTICENAME          varchar(255),
    EVENTNAME           varchar(255),
    EMAILSERVICE        boolean,
    SHORTMESSAGESERVICE boolean,
    NOTICELEVEL         integer,
    REMARK              varchar(255)
);


create table DCC_NOTICE_USER
(
    ID         integer        not null
        primary key,
    GUID       varchar(38) not null
        constraint DCC_NOTICE_USER_GUID_UINDEX
            unique,
    USERGUID   varchar(38),
    NOTICEGUID varchar(38)
);


create table DCC_OPERATION
(
    ID           integer        not null
        primary key,
    GUID         varchar(38) not null
        constraint UK_RBNS89FR5MS76T4DJ4VTYDX7U
            unique,
    MASK         bigint,
    K_NAME       varchar(190),
    PRIORITY     integer,
    REMARK       varchar(255),
    RESOURCETYPE integer
);


create table DCC_ORG
(
    ID                   integer        not null
        primary key,
    GUID                 varchar(38) not null
        constraint UK_TGC1MNEOU9AU9KWQBKYKLAO8W
            unique,
    CONTACTTELEPHONE     varchar(255),
    CREATEDATE           TIMESTAMP(6),
    FULLNAME             varchar(255),
    ORGCODE              varchar(255),
    ORGTYPE              integer,
    PARENTGUID           varchar(38),
    PARENTID             integer,
    PY                   varchar(255),
    PYINITIALS           varchar(255),
    REMARK               varchar(255),
    RESPONSIBILITY       varchar(255),
    SHORTNAME            varchar(255),
    SORTNO               integer        not null,
    STATE                integer,
    SUPERVISIONTELEPHONE varchar(255),
    TREECODE             varchar(190)
        unique,
    ORGTYPE2             varchar(38)
);


create table DCC_ORG_ROLE
(
    ID       integer             not null
        primary key,
    GUID     varchar(38)           not null,
    ORGGUID  varchar(38)           not null,
    ROLEGUID varchar(38)           not null,
    SORTNO   integer default 9999 not null
);

comment on table DCC_ORG_ROLE is '岗位角色和机构之间的关系';


create table DCC_ORG_USER
(
    ID        integer   not null
        primary key,
    GUID      varchar(38) not null,
    ISMANAGER boolean,
    ORGGUID   varchar(38),
    ORGID     integer,
    SORTNO    integer,
    USERGUID  varchar(38),
    USERID    integer
);


create table DCC_PWD_HISTORY
(
    ID         integer        not null
        primary key,
    GUID       varchar(38) not null
        constraint UK_7V69L5U5FJFB5IOXKV3MBI2GR
            unique,
    CHANGETIME TIMESTAMP(6),
    PWD        varchar(255),
    K_TYPE     integer,
    USERGUID   varchar(38)
);


create table DCC_REALM
(
    ID     integer              not null
        primary key,
    GUID   varchar(38)       not null
        constraint UK_AXTL4PUW0V4MKDIW8U6KD7VXX
            unique,
    K_NAME varchar(190),
    K_TYPE integer,
    SORTNO integer default 9999 not null
);

create unique index DCC_REALM_INDEX_K_NAME_INDEX
    on DCC_REALM (K_NAME);

INSERT INTO DCC_REALM (ID, GUID, K_NAME, K_TYPE, SORTNO) VALUES (-1, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', '默认域', null, 9999);
create table DCC_REALM_MANAGER
(
    ID        integer        not null
        primary key,
    GUID      varchar(38) not null
        constraint UK_919AQ99OCCUVIHQ2RS7A4VSPK
            unique,
    REALMGUID varchar(38),
    USERGUID  varchar(38)
);

INSERT INTO DCC_REALM_MANAGER (ID, GUID, REALMGUID, USERGUID) VALUES (1326, '990CC0D4-8674-42FF-9417-AF5398815E21', 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', '85A2EE39-A64A-40AD-B9B1-A2389AA6A1AD');
INSERT INTO DCC_REALM_MANAGER (ID, GUID, REALMGUID, USERGUID) VALUES (1327, 'E770B3F1-04A9-4446-8E5F-9E7442B02F74', 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', '67C42486-97B0-4112-8D92-A39C6C683D54');
INSERT INTO DCC_REALM_MANAGER (ID, GUID, REALMGUID, USERGUID) VALUES (1328, '63FDB69B-6D5E-4C14-96F9-B77BB63C17C9', 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', '057293DA-90DA-4CCC-A253-BDFE61CD4DDD');
create table DCC_REALM_ORG
(
    ID        integer        not null
        primary key,
    GUID      varchar(38) not null
        constraint UK_SOH9GXTO6RRX89Y1BEJ4OOEEN
            unique,
    ORGGUID   varchar(38),
    REALMGUID varchar(38)
);


create table DCC_ROLE
(
    ID         integer           not null
        primary key,
    GUID       varchar(38)    not null
        constraint UK_L1CVJ1UPRM86OGATRR9MJNPS3
            unique,
    PARENTGUID varchar(38),
    REALMGUID  varchar(38),
    REMARK     varchar(255),
    ROLENAME   varchar(255),
    ROLETYPE   integer,
    SORTNO     integer           not null,
    MUTEXTYPE  integer default 0 not null
);

create index INDEX_ROLE_TYPE
    on DCC_ROLE (ROLETYPE);

INSERT INTO DCC_ROLE (ID, GUID, PARENTGUID, REALMGUID, REMARK, ROLENAME, ROLETYPE, SORTNO, MUTEXTYPE) VALUES (-1, '2E920191-DF41-4B44-B1FB-8757D4A5EF87', null, 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', '管理员组', '1', 0, -1, 0);
INSERT INTO DCC_ROLE (ID, GUID, PARENTGUID, REALMGUID, REMARK, ROLENAME, ROLETYPE, SORTNO, MUTEXTYPE) VALUES (1184, 'cc735573-de13-4ef4-a4c3-49f7e989c5c8', '2E920191-DF41-4B44-B1FB-8757D4A5EF87', 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', null, '审计管理员', 1, 3, 3);
INSERT INTO DCC_ROLE (ID, GUID, PARENTGUID, REALMGUID, REMARK, ROLENAME, ROLETYPE, SORTNO, MUTEXTYPE) VALUES (1185, 'e9005a27-d752-40fc-920a-c67d1512f370', '2E920191-DF41-4B44-B1FB-8757D4A5EF87', 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', null, '安全管理员', 1, 2, 2);
INSERT INTO DCC_ROLE (ID, GUID, PARENTGUID, REALMGUID, REMARK, ROLENAME, ROLETYPE, SORTNO, MUTEXTYPE) VALUES (1186, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', '2E920191-DF41-4B44-B1FB-8757D4A5EF87', 'B7C261BC-988F-4737-ABC4-ABC4BAC4ABDC', '系统配置管理员角色', '配置管理员', 1, 1, 1);
INSERT INTO DCC_ROLE (ID, GUID, PARENTGUID, REALMGUID, REMARK, ROLENAME, ROLETYPE, SORTNO, MUTEXTYPE) VALUES (1567, '21B01BFE-AEF7-4B1B-8551-B774C66B514B', null, 'EA78949F-6A37-443B-9482-A45C98FA9545', null, '公共角色管理', 1, 9999, 0);
create table DCC_ROLE_MEMBER
(
    ID         integer        not null
        primary key,
    GUID       varchar(38) not null
        constraint UK_446GBY2XPQR22LVPPN2BG0FU3
            unique,
    MEMBERGUID varchar(38),
    MEMBERTYPE integer,
    ROLEGUID   varchar(38),
    SORTNO     integer
);

create index INDEX_ROLEMEMBER_ROLE_MEMBER
    on DCC_ROLE_MEMBER (ROLEGUID, MEMBERGUID);

create index INDEX_ROLEMEMBER_MEMBER_ROLE
    on DCC_ROLE_MEMBER (MEMBERGUID, ROLEGUID);

create index INDEX_ROLEMEMBER_MEMBER
    on DCC_ROLE_MEMBER (MEMBERGUID);

create index INDEX_ROLEMEMBER_ROLE
    on DCC_ROLE_MEMBER (ROLEGUID);

INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (1323, 'CEDB8E3F-F9EB-4B40-9E0E-AD443E596A2B', '85A2EE39-A64A-40AD-B9B1-A2389AA6A1AD', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (1324, '667BF0D1-2E60-479B-B682-830F4538AD91', '67C42486-97B0-4112-8D92-A39C6C683D54', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (1325, 'E40D6CA3-BE81-4680-A192-B3E2576E84EC', '057293DA-90DA-4CCC-A253-BDFE61CD4DDD', 1, 'cc735573-de13-4ef4-a4c3-49f7e989c5c8', 1);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (1332, '44213EC7-028D-4489-8FBB-9FA80B184268', '85A2EE39-A64A-40AD-B9B1-A2389AA6A1AD', 1, '33b5f490-67cf-4d9d-afeb-ffd6c5f44da3', 1);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (1333, '384BC88D-D475-4B83-876F-B7DAB95114D5', '67C42486-97B0-4112-8D92-A39C6C683D54', 1, 'e9005a27-d752-40fc-920a-c67d1512f370', 1);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (1334, '9B6F670B-70BB-4A70-BD2F-A477F1B6F517', '057293DA-90DA-4CCC-A253-BDFE61CD4DDD', 1, 'cc735573-de13-4ef4-a4c3-49f7e989c5c8', 1);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (-1, '1', '-2', 1, '-1', 0);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (1568, '737EE6E8-F4A7-449F-A81B-BD68A0AB1341', '3023B612-E303-4F0C-B33C-B33C44DF8DFD', 1, '21B01BFE-AEF7-4B1B-8551-B774C66B514B', 62);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (1569, '813F30A0-CF00-48B7-BDB5-82ADCEF9EE02', '85A2EE39-A64A-40AD-B9B1-A2389AA6A1AD', 1, '21B01BFE-AEF7-4B1B-8551-B774C66B514B', 63);
INSERT INTO DCC_ROLE_MEMBER (ID, GUID, MEMBERGUID, MEMBERTYPE, ROLEGUID, SORTNO) VALUES (1570, '800A6233-2701-4BD2-8529-9B49D9E87C31', '67C42486-97B0-4112-8D92-A39C6C683D54', 1, '21B01BFE-AEF7-4B1B-8551-B774C66B514B', 64);
create table DCC_SQL_SCRIPT_EXE_LOG
(
    ID        integer        not null
        primary key,
    GUID      varchar(38) not null
        constraint UK_R7DIX707RL4I5XHY0HE2JH8QR
            unique,
    ERRORLOGS varchar(255),
    FILENAME  varchar(255)
);

INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1562, '677F965D297646998C0D334B0808EF8C', 'sql脚本内置插入语句', 'patch_2018_09_26_01_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1403, '22F81138624C438DA7F858D6F09425FD', 'sql脚本内置插入语句', 'patch_2018_07_08_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1407, '8B5B7DB0CEFF45E28B1F413E66F6A088', 'sql脚本内置插入语句', 'patch_2018_07_18_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1380, '1D6DB3F2DAB74F399E169F376AE2D4A6', 'sql脚本内置插入语句', 'patch_2018_05_24_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1040, '8F50F31584774E358F984351F348C2FC', 'sql脚本内置插入语句', 'patch_2017_07_17_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1041, '40BDB376F80F412BB5757CAF3E3567DF', 'sql脚本内置插入语句', 'patch_2017_07_22_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1048, 'CF0A532FBB004F69BEB0F407F6A762E6', 'sql脚本内置插入语句', 'patch_2017_07_26_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1089, '82EB8600A57D4892BB59D0CFF64A6385', 'sql脚本内置插入语句', 'patch_2017_07_27_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1091, 'EF703FACB98545B68360DC8C07F65413', 'sql脚本内置插入语句', 'patch_2017_07_28_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1096, '625F9A14B6E74C63B4E858A8420ADD17', 'sql脚本内置插入语句', 'patch_2017_07_30_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1097, '104FCA75B3844CCCB1DC66CEB4ECC3FB', 'sql脚本内置插入语句', 'patch_2017_08_01_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1100, '614C9BBFD9904A8187B092FCD6E94813', 'sql脚本内置插入语句', 'patch_2017_08_02_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1105, 'B9C431E5D4C64A83BFD1B10F50CD7186', 'sql脚本内置插入语句', 'patch_2017_08_04_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1106, '31734A15E53D4183A83CF4AE6E9DC90B', 'sql脚本内置插入语句', 'patch_2017_08_05_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1107, 'FE9E3985EF464F7DBF37840862D12B88', 'sql脚本内置插入语句', 'patch_2017_08_09_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1110, 'D554CAC65D0B4A64A760619D41645BDE', 'sql脚本内置插入语句', 'patch_2017_08_10_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1111, 'EBB96452D38E46DD86BF40AFE3668D93', 'sql脚本内置插入语句', 'patch_2017_08_18_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1116, 'D49A762029EA43ECBA09EF330D2140B4', 'sql脚本内置插入语句', 'patch_2017_08_21_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1119, 'F43B30B8E2D94C9F86E4BB3229976F7B', 'sql脚本内置插入语句', 'patch_2017_08_23_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1255, 'CFC4DC5EFEB34134852F6741E5008A6F', 'sql脚本内置插入语句', 'patch_2017_10_10_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1256, '330B21B7AC454EC9B726FA148459B7F8', 'sql脚本内置插入语句', 'patch_2017_10_15_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1257, '37CD1931E91444D4AA11AB62BEA8EE34', 'sql脚本内置插入语句', 'patch_2017_10_25_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1258, '5E43E32FA8A7496ABE17405B2FAEF4D3', 'sql脚本内置插入语句', 'patch_2017_10_27_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1273, 'A2F20DC34A6D4A2B98C7EE20BDCF303A', 'sql脚本内置插入语句', 'patch_2017_11_01_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1301, '82B8282F496F480499692F90DA2BC9C9', 'sql脚本内置插入语句', 'patch_2017_11_08_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1302, 'ACC93C26896247CFBCD9AA52EC6233BA', 'sql脚本内置插入语句', 'patch_2017_11_09_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1303, '4E39513EC81D49F293A8EBF801253A4A', 'sql脚本内置插入语句', 'patch_2017_11_14_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1318, '84562FC3C74C492AADB200620201BE31', 'sql脚本内置插入语句', 'patch_2017_11_19_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1319, '5502D711027F448695CE316010C45F2C', 'sql脚本内置插入语句', 'patch_2017_12_06_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (-1, '25a068f7-ec18-49e9-ae53-1a86d14215aa', null, 'patch_2017_06_12_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (-2, '1fe9aabc-88f7-4549-9142-9bf29cbeb98f', null, 'patch_2017_06_14_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (-3, '4c3b0abe-4f67-44e8-a7ef-a04c1f5533a1', null, 'patch_2017_06_15_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (-4, 'b1b4bfbf-0589-449a-b5bb-c006841188f0', null, 'patch_2017_06_19_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1120, '4D0EC2C665F241228774E7445F83C68E', 'sql脚本内置插入语句', 'patch_2017_09_07_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1251, '717943A76D5143BA91FFD3174132EC85', 'sql脚本内置插入语句', 'patch_2017_09_12_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1252, '3226BA90A2DE4BFEBEB27F7029020360', 'sql脚本内置插入语句', 'patch_2017_09_22_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1253, '8BB2088D41424E62A75E02E0395673C3', 'sql脚本内置插入语句', 'patch_2017_09_27_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1254, '1C2C6034638A4DB3B0D08E72B60682C4', 'sql脚本内置插入语句', 'patch_2017_09_30_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1341, '3C02F9F363CC493E9EA6A5AC189F478A', 'sql脚本内置插入语句', 'patch_2017_12_21_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1363, '32C113022DEF4BF08C062B2EF3E55E3E', 'sql脚本内置插入语句', 'patch_2017_12_25_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1370, '2F6FDD0E4F6C4E348DE20396276CCD8F', 'sql脚本内置插入语句', 'patch_2018_01_05_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1374, 'A6370FBBD01C41BB9A9BDEE3DA4519D2', 'sql脚本内置插入语句', 'patch_2018_03_08_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1378, 'DAA489795270418C958AB14C972FBDF7', 'sql脚本内置插入语句', 'patch_2018_04_27_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1554, '01CD7931A4354AA6B2FB815088667877', 'sql脚本内置插入语句', 'patch_2018_08_30_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1576, '802CAABCB5F54B6D93BA86C4D5512E33', 'sql脚本内置插入语句', 'patch_2018_09_26_02_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1639, 'AB814A68858844749DE0C54776C37A56', 'sql脚本内置插入语句', 'patch_2018_09_26_03_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1642, 'AFE714F572C643B69C005AD62216100B', 'sql脚本内置插入语句', 'patch_2018_11_27_01_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1670, 'FFF8CB8EC4594F1E95EDB0F2743D0BA9', 'sql脚本内置插入语句', 'patch_2018_11_27_02_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1777, 'E939459317434E5DA5064503CA48450C', 'sql脚本内置插入语句', 'patch_2018_11_27_03_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1786, 'A068D33DFCB8CEDDE05011AC080007EB', 'sql脚本内置插入语句', 'patch_2018_12_06_01_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1793, 'A068D33F70765AE9E05011AC080007ED', 'sql脚本内置插入语句', 'patch_2018_12_29_01_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1798, 'A068D34220542D5BE05011AC080007F3', 'sql脚本内置插入语句', 'patch_2019_06_28_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1807, 'A068D3445697392FE05011AC080007F5', 'sql脚本内置插入语句', 'patch_2019_07_03_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1809, 'A068D349120DFDD1E05011AC080007F9', 'sql脚本内置插入语句', 'patch_2019_07_30_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1811, 'A068D3573BD8941BE05011AC080007FD', '补丁脚本已执行', 'patch_2019_09_26_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1815, 'A068D36149D989CDE05011AC08000803', '补丁脚本已执行', 'patch_2019_11_06_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1819, 'A068D367C529C0FDE05011AC08000807', '补丁脚本已执行', 'patch_2020_02_20_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1820, 'A068D36AAEADEA46E05011AC0800080B', '补丁脚本已执行', 'patch_2020_03_07_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1795, 'A068D340E42AE967E05011AC080007F1', 'sql脚本内置插入语句', 'patch_2019_06_03_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1808, 'A068D34593607A7DE05011AC080007F7', 'sql脚本内置插入语句', 'patch_2019_07_16_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1810, 'A068D34A8616099CE05011AC080007FB', '补丁脚本已执行', 'patch_2019_09_07_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1812, 'A068D35F1B53BB5BE05011AC08000801', '补丁脚本已执行', 'patch_2019_10_31_oracle.sql');
INSERT INTO DCC_SQL_SCRIPT_EXE_LOG (ID, GUID, ERRORLOGS, FILENAME) VALUES (1816, 'A068D36490F18C89E05011AC08000805', '补丁脚本已执行', 'patch_2019_11_07_oracle.sql');
create table DCC_STATION
(
    ID       integer        not null
        primary key,
    GUID     varchar(38) not null
        constraint UK_CNO41TJJ22LHGTH37YVNDWWW8
            unique,
    ORGGUID  varchar(38),
    ROLEGUID varchar(38),
    SORTNO   integer        not null,
    USERGUID varchar(38)
);


create table DCC_SYNC_APP
(
    ID                          integer        not null
        primary key,
    GUID                        varchar(38) not null
        constraint UK_DDVOTMBV0IB34AIBV1BPASAE
            unique,
    ACTUALDATAFIELDNAMEINRESULT varchar(20),
    AUTOSYNCSCHEDULE            varchar(100),
    DBDRIVER                    varchar(100),
    DBPASSWORD                  varchar(40),
    DBURL                       varchar(200),
    DBUSER                      varchar(40),
    ISAUTO                      boolean,
    LASTSYNCTIME                TIMESTAMP(6),
    LDAPBINDPASSWORD            varchar(40),
    LDAPBINDUSER                varchar(40),
    LDAPPORT                    varchar(10),
    LDAPSERVER                  varchar(200),
    K_NAME                      varchar(40) not null,
    PINYININITIALS              varchar(40),
    REMARK                      varchar(255),
    SERVICEDATAIDFIELDNAME      varchar(20),
    SORTNO                      integer,
    SYNCDATAACCESSTYPE          integer,
    K_TYPE                      integer
);


create table DCC_SYNC_TASK
(
    ID                      integer        not null
        primary key,
    GUID                    varchar(38) not null
        constraint UK_6R3XPQEOYG5UE3QWDSEFB0DCI
            unique,
    APPGUID                 varchar(38),
    DATANOTIFYURL           varchar(100),
    DBSPECIALCOLUMNS        varchar(200),
    DBTABLE                 varchar(40),
    ENTITYMATCHFIELDSMAP    varchar(200),
    ISENABLED               boolean,
    LDAPENTITYCLASS         varchar(40),
    LDAPENTITYCONTAINERDN   varchar(200),
    LDAPENTITYMEMBERATTR    varchar(40),
    LDAPENTITYRDNATTR       varchar(40),
    LDAPMEMBERCLASS         varchar(40),
    LDAPMEMBERCONTAINERDN   varchar(200),
    LDAPMEMBERRDNATTR       varchar(40),
    LDAPSPECIALATTRS        varchar(200),
    MEMBERMATCHFIELDSMAP    varchar(200),
    K_NAME                  varchar(40) not null,
    PINYININITIALS          varchar(40),
    REMARK                  varchar(255),
    SORTNO                  integer,
    SYNCCONFLITSTRATEGY     integer,
    SYNCDIRECTION           integer,
    SYNCFIELDMAPS           varchar(200),
    SYNCRESTSERVICEURL      varchar(100),
    SYNCTYPE                integer,
    SYNCFILTERCONDITIONS    varchar(100),
    APPGENERATETREEFIELDMAP varchar(32)
);

create unique index DCC_TASK_INDEX_K_NAME_INDEX
    on DCC_SYNC_TASK (K_NAME);


create table DCC_SYNC_TASK_LOG
(
    ID                        integer        not null
        primary key,
    GUID                      varchar(38) not null
        constraint UK_7S1F3F3L0CHRBXWNYOM4BE6CL
            unique,
    APP_ID                    varchar(38),
    APP_NAME                  varchar(40),
    DB_ADD_FAIL_COUNT         integer,
    DB_ADD_SUCCESS_COUNT      integer,
    DB_ADD_COUNT              integer,
    DB_CHECK_FAIL_COUNT       integer,
    DB_DELETE_FAIL_COUNT      integer,
    DB_DELETE_SUCCESS_COUNT   integer,
    DB_DELETE_COUNT           integer,
    DB_MODIFY_FAIL_COUNT      integer,
    DB_MODIFY_SUCCESS_COUNT   integer,
    DB_MODIFY_COUNT           integer,
    ELAPSED_TIME              bigint,
    END_TIME                  TIMESTAMP(6),
    LDAP_ADD_FAIL_COUNT       integer,
    LDAP_ADD_SUCCESS_COUNT    integer,
    LDAP_ADD_COUNT            integer,
    LDAP_CHECK_FAIL_COUNT     integer,
    LDAP_DELETE_FAIL_COUNT    integer,
    LDAP_DELETE_SUCCESS_COUNT integer,
    LDAP_DELETE_COUNT         integer,
    LDAP_MODIFY_FAIL_COUNT    integer,
    LDAP_MODIFY_SUCCESS_COUNT integer,
    LDAP_MODIFY_COUNT         integer,
    START_TIME                TIMESTAMP(6),
    STATUS                    integer,
    STATUS_NAME               varchar(40),
    TASK_ID                   varchar(38),
    TASK_NAME                 varchar(40)
);


create table DCC_SYNC_TASK_LOG_DETAIL
(
    ID         integer        not null
        primary key,
    GUID       varchar(38) not null
        constraint UK_O6SQCJ3FJGG0K9AQNB61QK2CL
            unique,
    APPGUID    varchar(38),
    LOGGUID    varchar(38),
    NEWDATA    varchar(1024),
    OLDDATA    varchar(1024),
    RESULT     varchar(1024),
    STATUS     integer,
    STATUSNAME varchar(40),
    TASKGUID   varchar(38),
    TIME       TIMESTAMP(6),
    K_TYPE     integer,
    TYPENAME   varchar(40)
);


create table DCC_USER
(
    ID             integer              not null
        primary key,
    GUID           varchar(38)       not null
        constraint UK_OD7LX47CCDNPQ85G963BMW7HJ
            unique,
    CREATEDATE     TIMESTAMP(6),
    EMAIL          varchar(255),
    ICONURL        varchar(255),
    LASTONLINEDATE TIMESTAMP(6),
    LOGINNAME      varchar(64)            not null
        unique,
    LOGINPWD       varchar(255),
    MOBILEPHONE    varchar(255)
        unique,
    POSTCODE       varchar(255),
    PY             varchar(255),
    REALMGUID      varchar(38),
    REMARK         varchar(255),
    SIGNPWD        varchar(255),
    SORTNO         integer              not null,
    STATE          integer,
    TELEPHONE      varchar(255),
    USERNAME       varchar(255),
    USERTYPE       integer,
    ISLOCKED       boolean   default false,
    LOGINFAILCOUNT integer  default 0   not null,
    ISINSTAFF      boolean   default false   not null,
    JOBNUMBER      varchar(38),
    K_LEVEL        varchar(8) default '8' not null,
    RESERVEDSTR1   varchar(255)
);

INSERT INTO DCC_USER (ID, GUID, CREATEDATE, EMAIL, ICONURL, LASTONLINEDATE, LOGINNAME, LOGINPWD, MOBILEPHONE, POSTCODE, PY, REALMGUID, REMARK, SIGNPWD, SORTNO, STATE, TELEPHONE, USERNAME, USERTYPE, ISLOCKED, LOGINFAILCOUNT, ISINSTAFF, JOBNUMBER, K_LEVEL, RESERVEDSTR1) VALUES (1320, '85A2EE39-A64A-40AD-B9B1-A2389AA6A1AD', TO_TIMESTAMP('2017-12-14 10:55:30.000000', 'YYYY-MM-DD HH24:MI:SS.FF6'), null, null, null, 'admin-c', 'nWdsNc8K0PmetFxQvBzrmQ==', null, null, null, null, null, 'nWdsNc8K0PmetFxQvBzrmQ==', 1, 1, null, '全局配置管理员', 1, false, 0, false, null, '8', null);
INSERT INTO DCC_USER (ID, GUID, CREATEDATE, EMAIL, ICONURL, LASTONLINEDATE, LOGINNAME, LOGINPWD, MOBILEPHONE, POSTCODE, PY, REALMGUID, REMARK, SIGNPWD, SORTNO, STATE, TELEPHONE, USERNAME, USERTYPE, ISLOCKED, LOGINFAILCOUNT, ISINSTAFF, JOBNUMBER, K_LEVEL, RESERVEDSTR1) VALUES (1321, '67C42486-97B0-4112-8D92-A39C6C683D54', TO_TIMESTAMP('2017-12-14 10:55:30.000000', 'YYYY-MM-DD HH24:MI:SS.FF6'), null, null, null, 'admin-s', 'nWdsNc8K0PmetFxQvBzrmQ==', null, null, null, null, null, 'nWdsNc8K0PmetFxQvBzrmQ==', 1, 1, null, '全局安全管理员', 1, false, 0, false, null, '8', null);
INSERT INTO DCC_USER (ID, GUID, CREATEDATE, EMAIL, ICONURL, LASTONLINEDATE, LOGINNAME, LOGINPWD, MOBILEPHONE, POSTCODE, PY, REALMGUID, REMARK, SIGNPWD, SORTNO, STATE, TELEPHONE, USERNAME, USERTYPE, ISLOCKED, LOGINFAILCOUNT, ISINSTAFF, JOBNUMBER, K_LEVEL, RESERVEDSTR1) VALUES (1322, '057293DA-90DA-4CCC-A253-BDFE61CD4DDD', TO_TIMESTAMP('2017-12-14 10:55:30.000000', 'YYYY-MM-DD HH24:MI:SS.FF6'), null, null, null, 'admin-a', 'nWdsNc8K0PmetFxQvBzrmQ==', null, null, null, null, null, 'nWdsNc8K0PmetFxQvBzrmQ==', 1, 1, null, '全局审计管理员', 1, false, 0, false, null, '8', null);
create table DCC_USER_AGENT
(
    ID         integer        not null
        primary key,
    GUID       varchar(38) not null
        constraint UK_AGENT
            unique,
    CLIENTGUID varchar(38) not null,
    AGENTGUID  varchar(38) not null,
    BEGINTIME  TIMESTAMP(6),
    ENDTIME    TIMESTAMP(6)
);


create table DCC_USER_SHORTCUT
(
    ID           integer        not null
        primary key,
    GUID         varchar(38) not null
        constraint "UNIQUE"
            unique,
    FUNCTIONGUID varchar(38)      not null,
    K_NAME       varchar(190)     not null,
    SORTNO       integer,
    USERGUID     varchar(38)      not null
);

