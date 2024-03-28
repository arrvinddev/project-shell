script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh


func_print_head "Install Redis Repos "
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>$log_file
func_stat_check $? 

func_print_head "Enable Redis 6.2"
dnf module enable redis:remi-6.2 -y &>>$log_file
dnf install redis -y &>>$log_file
func_stat_check $? 

func_print_head "Update Redis listen address ,Change Redis conf file from localhost to 0.0.0.0"
sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/redis.conf &>>$log_file
sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/redis/redis.conf &>>$log_file
func_stat_check $? 

func_print_head "Start Redis service"
systemctl enable redis  &>>$log_file
systemctl start redis   &>>$log_file
func_stat_check $? 
