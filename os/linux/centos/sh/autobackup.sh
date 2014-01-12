#!/bin/bash
#��Ҫ�޸ĵĵط������￪ʼ
MYSQL_USER=                      #mysql�û���
MYSQL_PASS=                      #mysql����
MAIL_TO=                         #���ݿⷢ�͵�������
FTP_USER=                        #ftp�û���
FTP_PASS=                        #ftp����
FTP_IP=                          #ftp��ַ
FTP_backup=                      #ftp�ϴ�ű����ļ���Ŀ¼,���Ҫ�Լ���ftp���潨��
WEB_DATA=                        #Ҫ���ݵ���վ����
#��Ҫ�޸ĵĵط����������

#�������ݿ�����ֺ;����ݿ������
DataBakName=Data_$(date +"%Y%m%d").tar.gz
WebBakName=Web_$(date +%Y%m%d).tar.gz
OldData=Data_$(date -d -5day +"%Y%m%d").tar.gz
OldWeb=Web_$(date -d -5day +"%Y%m%d").tar.gz
#ɾ������3��ǰ������
rm -rf /home/backup/Data_$(date -d -3day +"%Y%m%d").tar.gz /home/backup/Web_$(date -d -3day +"%Y%m%d").tar.gz
cd /home/backup
#�������ݿ�,һ�����ݿ�һ��ѹ���ļ�
for db in `/usr/bin/mysql -u$MYSQL_USER -p$MYSQL_PASS -B -N -e 'SHOW DATABASES' | xargs`; do
    (/usr/bin/mysqldump -u$MYSQL_USER -p$MYSQL_PASS ${db} | gzip -9 - > ${db}.sql.gz)
done
#ѹ�����ݿ��ļ�Ϊһ���ļ�
tar zcf /home/backup/$DataBakName /home/backup/*.sql.gz
rm -rf /home/backup/*.sql.gz
#�������ݿ⵽Email,������ݿ�ѹ����̫��,��ע������
echo "����42.*.*.19�����ݱ��ݣ������⡣����������Ϣ�Ƽ����޹�˾" | mail -a /home/backup/$DataBakName -s "$(date +"%Y%m%d")���ݱ���" $MAIL_TO
#ѹ����վ����
tar zcf /home/backup/$WebBakName $WEB_DATA
#�ϴ���FTP�ռ�,ɾ��FTP�ռ�5��ǰ������
ftp -v -n $FTP_IP << END
user $FTP_USER $FTP_PASS
type binary
cd $FTP_backup
delete $OldData
delete $OldWeb
put $DataBakName
put $WebBakName
bye
END