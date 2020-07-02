#character set需要设置为utf8mb4，否则部分汉字可能不正确；collate需要设置为utf8mb4_bin，否则查询将不区分大小写
create database dasc_test character set utf8mb4 collate utf8mb4_bin;
grant all on dasc_test.* to 'dcc_security'@'%' identified by "dcc_security";
flush privileges;
