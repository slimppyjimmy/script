-- ���ڴ�����ռ���Ҫʹ��sys�û���������dasc���ݿ���Ҫʹ��dcc_security�û���Ϊ�˱����޸����ݽű����п���ʱֱ�ӵ����ģ�����ʹ�ñ��ű��������
-- ʹ��system�û�������ռ�ts_dasc���û�DCC_SECURITY����Ȩ
@/u01/app/oracle/oracledata/XE/dasc-db.sql
--�л���dcc_security�û��������ᱻ������system�û���
disconnect
connect DCC_SECURITY/dcc_security
-- ����dubbo-monitor��
@/u01/app/oracle/oracledata/XE/dubbo-monitor.sql
-- ����dasc���������ݣ�oracle������sqlplusִ��gbk�����sql�е�to_timestamp���ܳ����⣬��ʱȥ������ʹ���ֹ�ִ�У�
-- @/u01/app/oracle/oracledata/XE/dasc-tb.sql
-- ����dasc�����������ݣ�oracle������sqlplusִ��gbk�����sql�е�to_timestamp���ܳ����⣬��ʱȥ������ʹ���ֹ�ִ�У�
-- @/u01/app/oracle/oracledata/XE/dasc-dev.sql
-- �˳�sqlplus��������Ҫ�ֹ��˳�
exit