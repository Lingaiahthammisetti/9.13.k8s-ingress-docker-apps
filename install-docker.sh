#!/bin/bash
USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-$TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo  -e "$G Script started executing at:$TIMESTAMP $N"

VALIDATE(){
if [ $1 -ne 0 ]
then 
   echo -e "$R $2... FAITURE $N"
   exit 1
else
   echo -e "$G $2..  SUCCESS $N"
fi
}
#checking root user or not.
if [ $USERID -ne 0 ]
then
   echo -e "$R Please run this script with root access $N"
   exit 1
else
   echo -e "$G You are super user. $SCRIPT_NAME"

fi 

yum install yum-utils -y &>>$LOGFILE
VALIDATE $? "Installing utils packages"

yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo &>>$LOGFILE
VALIDATE $? "adding Docker repo"

yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y &>>$LOGFILE
VALIDATE $? "Installing docker"

systemctl start docker &>>$LOGFILE
VALIDATE $? "Starting docker"

systemctl enable docker &>>$LOGFILE
VALIDATE $? "Enabling Docker"

usermod -aG docker ec2-user &>>$LOGFILE
VALIDATE $? "Adding ec2-user to docker group as secondary group"

echo -e "$G Logout and login again $N"


echo "******* Resize EBS Storage ****************"
# ec2 instance creation request for Docker expense project
# =============================================
# RHEL-9-DevOps-Practice
# t3.micro
# allow-everything
# 50 GB

lsblk &>>$LOGFILE
VALIDATE $? "check the partitions"

growpart /dev/nvme0n1 4 &>>$LOGFILE #t3.micro used only
VALIDATE $? "growpart to resize the existing partition to fill the available space"

lvextend -l +50%FREE /dev/RootVG/rootVol &>>$LOGFILE
VALIDATE $? "Extend the Logical Volumes Decide how much space to allocate to each logical volume."

lvextend -l +50%FREE /dev/RootVG/varVol &>>$LOGFILE
VALIDATE $? "Extend the Logical Volumes Decide how much space to allocate to each logical volume.-2"

xfs_growfs / &>>$LOGFILE
VALIDATE $? "For the root filesystem:"

xfs_growfs /var &>>$LOGFILE
VALIDATE $? "For the /var filesystem:"


echo "*************   eksctl installation - start *************"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp &>>$LOGFILE
VALIDATE $? "Installing eksctl "

mv /tmp/eksctl /usr/local/bin &>>$LOGFILE
VALIDATE $? "Moving eksctl from tmp to bin folder"

eksctl version &>>$LOGFILE
VALIDATE $? "eksctl version"
echo "*************   eksctl installation - completed *************"

echo "*************   kubectl installation - start *************"
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.30.0/2024-05-12/bin/linux/amd64/kubectl &>>$LOGFILE
VALIDATE $? "Installing kubectl"

chmod +x ./kubectl &>>$LOGFILE
VALIDATE $? "changing kubectl file permission to execute"

mv kubectl  /usr/local/bin/ &>>$LOGFILE
VALIDATE $? "Moving kubectl from current folder to bin folder"

kubectl version --client &>>$LOGFILE
VALIDATE $? "kubectl version "
echo "*************   kubectl installation - completed *************"

echo "*************Install Helm - Start*************"
#Installing Helm in Kubernetes
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 &>>$LOGFILE
VALIDATE $? "Downloading the Helm"

chmod 700 get_helm.sh &>>$LOGFILE
VALIDATE $? "changing helm file permission to 700"

./get_helm.sh &>>$LOGFILE
VALIDATE $? "Executing the Helm file"

helm --version &>>$LOGFILE
VALIDATE $? "Helm version"
echo "*************Install Helm - completed*************"

echo "*************kubens Setup - start*************"
#install Kubens installtion for expense namespace
git clone https://github.com/ahmetb/kubectx /opt/kubectx &>>$LOGFILE
VALIDATE $? "kubectx cloned... "

ln -s /opt/kubectx/kubens /usr/local/bin/kubens &>>$LOGFILE
VALIDATE $? "created kubens softlink"

kubens expense &>>$LOGFILE
VALIDATE $? "moved to default namespace to expense"
echo "*************kubens Setup - completed*************"

echo "*************Install K9s - Start*************"
#Installing K9s
curl -sS https://webinstall.dev/k9s | bash &>>$LOGFILE
VALIDATE $? "K9s Installed"

k9s --version
VALIDATE $? "K9s Vesion" &>>$LOGFILE
echo "*************Install K9s - completed*************"