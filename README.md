# LAMP-Setup-on-ECS-using-Terraform-
Create a LAMP Setup on ECS using Terraform 

LAMP - 

Components. LAMP stands for Linux, Apache, MySQL, and PHP. Together, they provide a proven set of software for delivering high-performance web applications. Each component contributes essential capabilities to the stack: Linux: The operating system.

ECS - 
Amazon Elastic Container Service (Amazon ECS) is a highly scalable and fast container management service. You can use it to run, stop, and manage containers on a cluster.
With Amazon ECS, your containers are defined in a task definition that you use to run an individual task or task within a service.
In this context, a service is a configuration that you can use to run and maintain a specified number of tasks simultaneously in a cluster.
You can run your tasks and services on a serverless infrastructure that's managed by AWS Fargate. Alternatively, for more control over your infrastructure, you can run your tasks and services on a cluster of Amazon EC2 instances that you manage.

Launch types
There are two models that you can use to run your containers:
Fargate launch type - This is a serverless pay-as-you-go option. You can run containers without needing to manage your infrastructure.
EC2 launch type - Configure and deploy EC2 instances in your cluster to run your containers.

The Fargate launch type is suitable for the following workloads:
Large workloads that need to be optimized for low overhead
Small workloads that have occasional burst
Tiny workloads
Batch workloads
Amazon ECS provides the following features:
A serverless option with AWS Fargate. With AWS Fargate, you don't need to manage servers, handle capacity planning, or isolate container workloads for security. Fargate handles the infrastructure management aspects of your workload for you. You can schedule the placement of your containers across your cluster based on your resource needs, isolation policies, and availability requirements.

Integration with AWS Identity and Access Management (IAM). You can assign granular permissions for each of your containers. This allows for a high level of isolation when building your applications. In other words, you can launch your containers with the security and compliance levels that you've come to expect from AWS.

AWS managed container orchestration. As a fully managed service, Amazon ECS comes with AWS configuration and operational best practices built-in. This also means that you don't need to manage control plane, nodes, or add-ons. It's integrated with both AWS and third-party tools, such as Amazon Elastic Container Registry and Docker. This integration makes it easier for teams to focus on building the applications, not the environment.

NODE - Nodes can be a physical computer or a virtual machine (VMs). VMs are software programs in the cloud that allow you to emulate a physical computing environment with its own operating system (OS) and applications. 

CLUSTER - In a computer system, a cluster is a group of servers and other resources that act like a single system and enable high availability, load balancing and parallel processing. 

An Amazon ECS cluster is a logical grouping of tasks or services. You can use clusters to isolate your applications. This way, they don't use the same underlying infrastructure. When your tasks are run on Fargate, your cluster resources are also managed by Fargate.



Task Definition — This a blueprint that describes how a docker container should launch. If you are already familiar with AWS, it is like a LaunchConfig except instead it is for a docker container instead of a instance. It contains settings like exposed port, docker image, cpu shares, memory requirement, command to run and environmental variables.

Task — This is a running container with the settings defined in the Task Definition. It can be thought of as an “instance” of a Task Definition.

Service — Defines long running tasks of the same Task Definition. This can be 1 running container or multiple running containers all using the same Task Definition.



Lets Start Practical  -  

 First Open the AWS and Search for IAM 


After that Create IAM User and Apply the Administrator Access Policy and Click on Create.

 Download the Access Key and Secret Key CSV File.

 First Open the Terraform and Create New Folder Assignment 1

Create a first file name as Provider.tf  and Write the following code in it. 


terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "4.27.0"
   }
 }
}
provider "aws" {
 
 profile = "suyog"
}


 Provider.tf -  The Provider is AWS and the source is hashicorp/aws 
The Access Key and Secret Key is hidden from the public and put it into profile by using the aws configure.
            Access_Key = “XXXXXXX”
            Secret_Key = “XXXXXXXX”
             Region  = “US-West-2”


    2. Vpc.tf - The File is created for Creating the VPC (Virtual Private Network) in the AWS   
        Region  

 
resource "aws_vpc" "ecsvpc" {
 cidr_block       = "10.0.0.0/16"
 instance_tenancy = "default"
 
 tags = {
   Name = "ecsvpc"
 }
}
 

In the Given Code the AWS Resource is aws_vpc and we given label is as ecsvpc.
Then we put the CIDR Block for the VPC is “10.0.0.0/16”
And Tenancy is set to default 
Given tag name is ecsvpc

3. Subnet.tf -  We have created the One Private Subnet in this ecs vpc.

resource "aws_subnet" "public" {
 vpc_id                  = aws_vpc.ecsvpc.id
 cidr_block              = "10.0.1.0/24"
 map_public_ip_on_launch = true //it makes this a public subnet
 availability_zone       = "us-west-2a"
 
 tags = {
   Name = "Public"
 }
}

Our AWS resource is aws_subnet we set it as public subnet.
In second line the vpc_id is our created vpc name it as a aws_vpc.ecs.id  
In third line map_public_ip_on_launch = true means it assign the public ip 
After that we want to created the subnet in which availability zone we gave name as a 
“us -west-2a”
In the tag we gave name as a Public.
 
4. internetgateway.tf -  The Subnet which we are created It access the internet we need the Internet Gateway. So for that we use aws resource as aws_internet_gateway.
In the second line enter the vpc id = ecsvpc

resource "aws_internet_gataeway" "igw" {
 vpc_id = aws_vpc.ecsvpc.id
 
 tags = {
   Name = "IGW"
 }
}

5. routetable.tf-  
A routing table is a set of rules, often viewed in table format, that is used to determine where data packets traveling over an Internet Protocol (IP) network will be directed. All IP-enabled devices, including routers and switches, use routing tables.

resource "aws_route_table" "public-route" {
 vpc_id = aws_vpc.ecsvpc.id
 
 route {
   cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw.id
 }
}
 

Aws resource is aws_route_table and Label is public-route 
Connect with  VPC name as a ecsvpc
And route CIDR block is “0.0.0.0/0” and attach with Internet gateway to access the internet.

After creating the route table it need be associated with the public subnet gives the subnet id = public and route table name is public-route.id
resource "aws_route_table_association" "public" {
 subnet_id      = aws_subnet.public.id
 route_table_id = aws_route_table.public-route.id
}


6. securitygroup.tf - A security group acts as a virtual firewall for your EC2 instances to control incoming and outgoing traffic. Inbound rules control the incoming traffic to your instance, and outbound rules control the outgoing traffic from your instance. When you launch an instance, you can specify one or more security groups.

AWS Resource is aws_security_group and label  is “sg”
Name = ecs-sg – name of Security group 
There are two types of rules are defined in the Security Group 
Inbound Rule  = Ingress
Outbound Rule  = Egress

Inbound rules control the incoming traffic to your instance, and outbound rules control the outgoing traffic from your instance. 

So in the Ingress we allowed to connect with the internet using the port 80 and protocol http 
And in the Egress we are not allowed to connect thats why we put the value is 0

resource "aws_security_group" "sg" {
 name   = "ecs-sg"
 vpc_id = aws_vpc.ecsvpc.id
 
 ingress {
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   self        = "false"
   cidr_blocks = ["0.0.0.0/0"]
   description = "http"
 }
 
 egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }
}


Ecs.tf - An Amazon ECS cluster is a logical grouping of tasks or services. Your tasks and services are run on infrastructure that is registered to a cluster.
    
   1.In the first line we create the resource name as “aws_ecs_cluster” and label is ecscluster
   2. Name given is cluster 
   3. In third line create the container inside the cluster
   4. To allow the value is enabled 

 The Next resource we created name is ecs task definition and label it is as a task 
 family                   = "service"
 network_mode             = "awsvpc"
 requires_compatibilities = ["FARGATE", "EC2"] —-> Using these two types we create     
resources
 cpu                      = 512
 memory                   = 2048



     "name"      : "lamp", —-> Name of the Image 
     "image"     : "mattrayner/lamp:latest", —---> Image pull form the Dockerhub 
     "cpu"       : 512,  
     "memory"    : 2048,
     "essential" : true,
     "portMappings" : [
       {
         "containerPort" : 80, —---> Running on port number 80 

resource "aws_ecs_cluster" "ecscluster" {
 name = "cluster"
 setting {
   name  = "containerInsights"
   value = "enabled"
 }
}
 
resource "aws_ecs_task_definition" "task" {
 family                   = "service"
 network_mode             = "awsvpc"
 requires_compatibilities = ["FARGATE", "EC2"]
 cpu                      = 512
 memory                   = 2048
 container_definitions    = <<DEFINITION
 [
   {
     "name"      : "lamp",
     "image"     : "mattrayner/lamp:latest",
     "cpu"       : 512,
     "memory"    : 2048,
     "essential" : true,
     "portMappings" : [
       {
         "containerPort" : 80,
         "hostPort"      : 80
       }
     ]
 
   }
 ]
 DEFINITION
}
 
resource "aws_ecs_service" "service" {
 name             = "service"
 cluster          = aws_ecs_cluster.ecscluster.id
 task_definition  = aws_ecs_task_definition.task.id
 desired_count    = 1
 launch_type      = "FARGATE"
 platform_version = "LATEST"
 
 network_configuration {
   assign_public_ip = true
   security_groups  = [aws_security_group.sg.id]
   subnets          = [aws_subnet.public.id]
 }
 lifecycle {
   ignore_changes = [task_definition]
 }
}

Last  resource we use name aws_ecs_service and label gives as “service”
 name             = "service"  —---> Replica of Image 
 cluster          = aws_ecs_cluster.ecscluster.id —-> Group of Nodes
 task_definition  = aws_ecs_task_definition.task.id —--> Task Blueprint
 desired_count    = 1 —------> How Many Replica we want to create 
 launch_type      = "FARGATE" —---> Fargate type (Serverless)
 platform_version = "LATEST"  —----> Version 
 
 network_configuration {
   assign_public_ip = true    —----> Assign the Ip automatically
   security_groups  = [aws_security_group.sg.id] —----> security group which we created
   subnets          = [aws_subnet.public.id]  —-----> subnet our public subnet 
 }
 lifecycle {
   ignore_changes = [task_definition] —----> Perform the task continuously 
 }
}

After written all of the configuration in the terraform we Open the terminal and insert the command in it 

terraform init  —> To initialize the the workspace and download required dependencies 
terraform plan —-> To plan the resources which want to creat resources.
terraform apply —--> To apply all the configuration we use apply command.


Then Go to the AWS Console and Open the ECS Cluster shows same configuration which we are written in terrform code

Services are created

Task defination is LAMP 

LAMP Configuration- 

Memory and CPU which we are putted 

LAMP Configuration

Created Task 

Copy the Public IP Address and in Network Portion and Paste in to the browser. 
And It Shows the result. 
Our terraform setup is applied successfully. 

