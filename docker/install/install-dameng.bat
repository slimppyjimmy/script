rem ��ʼ��װ���� ...
docker stop dameng
docker rm -f dameng
set workdir=%cd:~0,2%\var\docker
cd /d %workdir%
rd /q /s dameng
md dameng\data
docker run --name dameng -d -p 8786:5236 -v %workdir%\dameng\data:/data wusuopu/dameng:dm8
rem ��װ�ɹ�
pause