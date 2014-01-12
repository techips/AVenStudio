#!/bin/bash
#你要修改的地方从这里开始
MYSQL_USER=                      #mysql用户名
MYSQL_PASS=                      #mysql密码
MAIL_TO=                         #数据库发送到的邮箱
FTP_USER=                        #ftp用户名
FTP_PASS=                        #ftp密码
FTP_IP=                          #ftp地址
FTP_backup=                      #ftp上存放备份文件的目录,这个要自己得ftp上面建的
WEB_DATA=                        #要备份的网站数据
#你要修改的地方从这里结束

#定义数据库的名字和旧数据库的名字
DataBakName=Data_$(date +"%Y%m%d").tar.gz
WebBakName=Web_$(date +%Y%m%d).tar.gz
OldData=Data_$(date -d -5day +"%Y%m%d").tar.gz
OldWeb=Web_$(date -d -5day +"%Y%m%d").tar.gz
#删除本地3天前的数据
rm -rf /home/backup/Data_$(date -d -3day +"%Y%m%d").tar.gz /home/backup/Web_$(date -d -3day +"%Y%m%d").tar.gz
cd /home/backup
#导出数据库,一个数据库一个压缩文件
for db in `/usr/bin/mysql -u$MYSQL_USER -p$MYSQL_PASS -B -N -e 'SHOW DATABASES' | xargs`; do
    (/usr/bin/mysqldump -u$MYSQL_USER -p$MYSQL_PASS ${db} | gzip -9 - > ${db}.sql.gz)
done
#压缩数据库文件为一个文件
tar zcf /home/backup/$DataBakName /home/backup/*.sql.gz
rm -rf /home/backup/*.sql.gz
#发送数据库到Email,如果数据库压缩后太大,请注释这行
echo "来自42.*.*.19的数据备份，请留意。——中络信息科技有限公司" | mail -a /home/backup/$DataBakName -s "$(date +"%Y%m%d")数据备份" $MAIL_TO
#压缩网站数据
tar zcf /home/backup/$WebBakName $WEB_DATA
#上传到FTP空间,删除FTP空间5天前的数据
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