script=$(realpath "$0")
script_path=$(dirname "$script")
source ${script_path}/common.sh


func_print_head "Install nginx"
yum install nginx -y &>>$log_file
func_stat_check $? 

func_print_head "copy roboshop conf file"
cp ${script_path}/roboshop.conf /etc/nginx/default.d/roboshop.conf &>>$log_file
func_stat_check $? $log_file


func_print_head "remove files in nginx folder"
rm -rf /usr/share/nginx/html/* &>>$log_file
func_stat_check $?

func_print_head "Download artifact and unzip frontend application"
curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip  &>>$log_file
func_stat_check $?

func_print_head "Unzip frontend contents"
cd /usr/share/nginx/html  &>>$log_file
unzip /tmp/frontend.zip &>>$log_file
func_stat_check $?

func_print_head "Start nginx service"
systemctl enable nginx &>>$log_file
systemctl restart nginx &>>$log_file
func_stat_check $?
