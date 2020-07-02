#删除初始化脚本，避免container重启后再次初始化从而导致数据丢失。注意本脚本的文件名必须是所有初始化sh、sql文件中按字母顺序排在最后，从而保证在其他初始化脚本执行完毕之后再执行
rm -rf /docker-entrypoint-initdb.d/*
