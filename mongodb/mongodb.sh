script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh

func_print_head "copy mongo repo file"
cp mongo.repo /etc/yum.repos.d/mongo.repo &>>$log_file
func_stat_check $? &>>$log_file

func_print_head "install mongodb"
yum install mongodb-org -y &>>$log_file
func_stat_check $?

func_print_head "Replace the ip to 0.0.0.0 in conf fie"
sed -i -e 's|127.0.0.1|0.0.0.0|' /etc/mongod.conf &>>$log_file
func_stat_check $?

func_print_head "Enable and Start Mongodb service"
systemctl enable mongod &>>$log_file
systemctl restart mongod &>>$log_file
func_stat_check $?
