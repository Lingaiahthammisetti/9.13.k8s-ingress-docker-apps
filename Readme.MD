# How to build and run dockerfile for ingress controller?
cd app1
docker build -t app1:v1.0 .

cd app2
docker build -t app2:v1.0 .

cd app3
docker build -t app3:v1.0 .

https://hub.docker.com/
docker login -u lingadevops -p ExpenseApp@1

docker tag app1:v1.0 lingadevops/app1:v1.0 
docker push lingadevops/app1:v1.0 

docker tag app1:v1.0 lingadevops/app2:v1.0 
docker push lingadevops/app2:v1.0 

docker tag app1:v1.0 lingadevops/app3:v1.0 
docker push lingadevops/app3:v1.0 



