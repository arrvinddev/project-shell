app_user=roboshop
script=$(realpath "$0")
script_path=$(dirname "$script")
log_file=/tmp/roboshop.log
rm -rf $log_file

func_print_head(){
echo -e "\e[35m >>>>>>>>$1<<<<<<<<<<<<<<<<\e[0m"
echo -e "\e[35m >>>>>>>>$1<<<<<<<<<<<<<<<<\e[0m" &>> $log_file
}

func_stat_check(){

if [ $1 = 0 ]; then 
echo -e "\e[32mSUCCESS\e[0m"
else 
echo -e "\e[31mFAILURE\e[0m"
echo "Refer the log file /tmp/roboshop.log for more information"
exit 1
fi

}

func_schema_setup(){
if [ "$schema_setup" == "mongo" ]; then 
func_print_head "Creating mongo repo file"
cp $script_path/mongo.repo /etc/yum.repos.d/mongo.repo &>> $log_file
func_stat_check $?

func_print_head "Install MongoDB Client"
yum install mongodb-org-shell -y &>> $log_file
func_stat_check $?

func_print_head "Load Schema"
mongo --host mongodb-dev.arrvind.tech </app/schema/${component}.js  &>> $log_file
func_stat_check $?
fi

if [ "$schema_setup" == "mysql" ]; then

func_print_head "Install MySQL"

yum install mysql -y  &>> $log_file
func_stat_check $?

func_print_head "Load Schema"

mysql -h mysql-dev.arrvind.tech -uroot -p${mysql_root_password} < /app/schema/shipping.sql &>> $log_file
func_stat_check $?

fi
}

func_app_prereq(){

func_print_head "Create Application user"
#ip=$(id $app_user)
#if [ $? -eq 0 ]; then
#  echo "roboshop user exists" # Do something here
#else
#  echo "Fail" # Fallback mode
#  useradd ${app_user} &>> $log_file
#  echo "Added roboshop user successfully"
#fi
id ${app_user} &>>/tmp/roboshop.log
if [ $? -ne 0 ]; then
    useradd ${app_user} &>>/tmp/roboshop.log
fi

func_stat_check $?
func_print_head "Create Application directory"
rm -rf /app &>> $log_file
mkdir /app &>> $log_file
func_stat_check $?
func_print_head "Download Artifact and unzip ${component} Application"
curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip  &>> $log_file
func_stat_check $?
cd /app 
unzip /tmp/${component}.zip  &>> $log_file
func_stat_check $?


}

func_systemd_setup(){

func_print_head "Creating ${component} service file"
cp ${script_path}/${component}.service /etc/systemd/system/${component}.service &>> $log_file
func_stat_check $? &>> $log_file
func_print_head "Start ${component} Service" &>> $log_file
systemctl daemon-reload &>> $log_file

systemctl enable ${component} &>> $log_file
systemctl restart ${component} &>> $log_file
func_stat_check $?

}


func_nodejs(){
func_print_head "Configuring repo for ${component}" 
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> $log_file
func_stat_check $?
#func_print_head "Disable and Enable Nodejs"  
#dnf module disable nodejs -y
#dnf module enable nodejs:18 -y
func_print_head "Install Nodejs" 
yum install nodejs -y &>> $log_file
func_stat_check $?

func_app_prereq

cd /app 
func_print_head "Install Nodejs in App directory"
npm install  &>> $log_file
func_schema_setup
func_systemd_setup

}

func_java(){

func_print_head "Install Maven Dependencies"  
yum install maven -y &>> $log_file
func_stat_check $?


func_app_prereq


func_print_head "Download maven dependencies"
mvn clean package  &>> $log_file
func_stat_check $?

mv target/shipping-1.0.jar shipping.jar &>> $log_file

func_schema_setup

func_systemd_setup

}

func_python(){
func_print_head "Install Python"
yum install python36 gcc python3-devel -y &>> $log_file
func_stat_check $?

func_app_prereq


func_print_head "Install Python dependencies"
pip3.6 install -r requirements.txt &>> $log_file
func_stat_check $?

func_print_head "Update Passwords in System Service file"
sed -i -e "s|rabbitmq_appuser_password|${rabbitmq_appuser_password}|" ${script_path}/payment.service &>> $log_file
func_stat_check $?

func_systemd_setup
}

#1> o/p  2> only error
#&> o/p and error in same file,  for append use &>>
#&>/dev/null