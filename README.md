# AWS 3-Tier Architecture with CloudFront, WAF, ALB, Auto Scaling, Secrets Manager, RDS and Live Application

## Overview

This document provides a complete step-by-step implementation of a production-style AWS 3-Tier Architecture using:

- Amazon CloudFront
- AWS WAF
- Application Load Balancer (ALB)
- Auto Scaling Group (ASG)
- Amazon EC2
- AWS Systems Manager (SSM)
- AWS Secrets Manager
- Amazon RDS MySQL
- NAT Gateways
- Multi-subnet VPC Design


# About the application:
Currently, we are using a simple note-taking application. The application prompts users to enter a username to log in. After logging in, users can create and save multiple notes, which are stored in the Amazon RDS MySQL database.

When a user accesses the application from a different browser or device and enters the same username, the application retrieves and displays all notes previously saved for that user from the database. This demonstrates persistent data storage and retrieval using Amazon RDS.

The application uses port 9051. It was built with python and HTML code.

---

## Architecture Diagram

```text


                               Internet Users  
                                      |  
                                      |  
                              Amazon CloudFront  
                                      |  
                                      |  
                        AWS WAF (attached to CloudFront)  
                                      |  
                                      |  
                       Application Load Balancer (ALB)  
                                      |  
            +----------------------------------------------+  
            |                                              |  
            |                                              |  
     Public-Web-Subnet-A                            Public-Web-Subnet-B  
      (us-east-1a)                                   	(us-east-1b)  
            |                                              |  
       NAT Gateway A                                  NAT Gateway B  
            |                                              |  
            +----------------------------------------------+  
                            		|  
                            		|  
        +---------------------------------------------------+
        |                                                  	|  
        |                                                  	|  
 Private-App-Subnet-A                              Private-App-Subnet-B  
    (us-east-1a)                                      	(us-east-1b)  
        |                                                  	|  
        |                                                  	|  
        +-------------- Auto Scaling Group -----------------+  
                            	|  
            +-----------------------------------+  
            |                               	|  
       EC2 App Server                     EC2 App Server  
          (APP-SG)                          (APP-SG)  
            |                               	|  
            +-----------------+-----------------+  
                            	|  
                     MySQL Port 3306  
                            	|  
                            	|  
               Private-DB-Subnet-A (us-east-1a)  
                            	|  
                    Amazon RDS MySQL  
                    Single-AZ Instance  
                       (DB-SG)

```
<img width="1774" height="887" alt="3-tier architecture diagram" src="https://github.com/user-attachments/assets/01080a6b-ff3f-4b7a-925b-fddfdfd6bd44" />

---


# VPC Creation
 Go to AWS \>\> VPC \>\> Create VPC \>\> VPC only \>\> Name tag: **3-tier VPC** \>\> IPv4 CIDR: **192.168.0.0/16** \>\> Create VPC.


  Select the VPC you created \>\> Actions \>\> Edit VPC settings \>\> DNS settings \>\> Enable DNS resolution: **Enable** \>\> Enable DNS hostnames: **Enable** \>\> Save.



# Subnet Creation
 Go to VPC \>\> subnets \>\> Create subnets \>\> VPC ID: Select **3-tier VPC** from the drop down \>\> 

  **Subnet 1:**  
  Subnet name: **Public-Web-subnet-A** \>\> Availability zone: **us-east-1a** \>\> IPv4 subnet CIDR block: 192.168.1.0/24 \>\> Add new subnet \>\>


  **Subnet 2:**

  Subnet name: **Public-Web-subnet-B** \>\> Availability zone: **us-east-1b** \>\> IPv4 subnet CIDR block: 192.168.2.0/24 \>\> Add new subnet \>\>


  **Subnet 3:**

  Subnet name: **Private-App-subnet-A** \>\> Availability zone: **us-east-1a** \>\> IPv4 subnet CIDR block: 192.168.11.0/24 \>\> Add new subnet \>\>


  **Subnet 4:**

  Subnet name: **Private-App-subnet-B** \>\> Availability zone: **us-east-1b** \>\> IPv4 subnet CIDR block: 192.168.12.0/24 \>\> Create Subnet.


  **Subnet 5:**

  Subnet name: **Private-Db-subnet-A** \>\> Availability zone: **us-east-1a** \>\> IPv4 subnet CIDR block: 192.168.21.0/24 \>\> Add new subnet \>\>


  **Subnet 6:**

  Subnet name: **Private-Db-subnet-B** \>\> Availability zone: **us-east-1b** \>\> IPv4 subnet CIDR block: 192.168.22.0/24 \>\> Create Subnet.


  


# Enable Auto Assign Public IP



  **Public-Web-subnet-A:**

  Go to VPC \>\> Subnets \>\> Public-Web-subnet-A \>\> Actions \>\> Edit subnet settings \>\> Auto-assign IP settings: Enable \>\> Save.


  **Public-Web-subnet-B:**

  Go to VPC \>\> Subnets \>\> Public-Web-subnet-B \>\> Actions \>\> Edit subnet settings \>\> Auto-assign IP settings: Enable \>\> Save.



# Internet Gateway Creation
 Go to VPC \>\> Internet Gateways \>\> Create Internet Gateway \>\> Name tag: **3-tier-igw** \>\> Create Internet Gateway \>\> Attach to a VPC \>\> Select the **3-tier VPC** from the drop down \>\> Attach internet gateway.


  


# NAT Gateway Creation
 One NAT per AZ. So a total of 2 NAT gateway will be created.


  **NAT-A:**

  Go to VPC \>\> NAT gateways \>\> Create NAT gateway \>\> Name: **NAT-A** \>\> Availability mode: **Zonal** \>\> Subnet: **Public-Web-subnet-A** \>\> Connectivity Type: Public \>\> Elastic IP allocation ID: Click on **Allocate Elastic IP** \>\> Create NAT gateway. (takes time to be up and running)


  **NAT-B:**

  Go to VPC \>\> NAT gateways \>\> Create NAT gateway \>\> Name: **NAT-B** \>\> Availability mode: **Zonal** \>\> Subnet: **Public-Web-subnet-B** \>\> Connectivity Type: Public \>\> Elastic IP allocation ID: Click on **Allocate Elastic IP** \>\> Create NAT gateway. (takes time to be up and running)


  


# Route Tables and Subnet Associations: 
You will need a public route table and 3 private route tables. (1 Public RT for Web subnets, 1 private RT for NAT-A, 1 private RT for NAT-B, and 1 private RT for Db).


  **Public Route table:**

  Go to VPC \>\> route tables \>\> Create route table \>\> Name: **Public-RT**  \>\> VPC: **3-tier VPC** \>\> Create route table \>\> Go to Routes \>\> Edit routes \>\> Add route \>\> Destination: 0.0.0.0/0 \>\> Target: Internet Gateway \>\> Select the Internet gateway ID: **3-tier-igw** \>\> Save changes \>\> Go to Subnet associations \>\> Edit Subnet associations \>\> Select the subnet: "**Public-Web-subnet-A**", "**Public-Web-subnet-B**" \>\> Save associations.


  **Private** **Route table App-RT-A:**

  Go to VPC \>\> route tables \>\> Create route table \>\> Name: **Private-App-RT-A**  \>\> VPC: **3-tier VPC** \>\> Create route table \>\> Go to Routes \>\> Edit routes \>\> Add route \>\> Destination: 0.0.0.0/0 \>\> Target: NAT Gateway \>\> Select the NAT gateway ID: **NAT-A** \>\> Save changes \>\> Go to Subnet associations \>\> Edit Subnet associations \>\> Select the subnet: "**Private-App-subnet-A**" \>\> Save associations.


  

  **Private** **Route table App-RT-B:**

  Go to VPC \>\> route tables \>\> Create route table \>\> Name: **Private-App-RT-B**  \>\> VPC: **3-tier VPC** \>\> Create route table \>\> Go to Routes \>\> Edit routes \>\> Add route \>\> Destination: 0.0.0.0/0 \>\> Target: NAT Gateway \>\> Select the NAT gateway ID: **NAT-B** \>\> Save changes \>\> Go to Subnet associations \>\> Edit Subnet associations \>\> Select the subnet: "**Private-App-subnet-B**" \>\> Save associations.


  **Private** **DB Route table:**

  Go to VPC \>\> route tables \>\> Create route table \>\> Name: **Private-DB-RT**  \>\> VPC: **3-tier VPC** \>\> Create route table \>\> No Routes attached here \>\> Go to Subnet associations \>\> Edit Subnet associations \>\> Select the subnet: "**Private-Db-subnet-A**"**,** "**Private-Db-subnet-B**" \>\> Save associations.


  


# Security Group Creation
 You need to create 4 Security Groups.


  **ALB-SG:** 

  Go to VPC \>\> Security Groups \>\> Create Security Group  \>\>  Security Group name: **ALB-SG** \>\> Description: **ALB-SG** \>\> VPC: **3-tier VPC** \>\> **Inbound rules** \>\> **Add rule** \>\> Type: HTTP \>\> Source Type: Anywhere-IPv4 \>\> Create Security Group.


  **APP-SG:** 

  Go to VPC \>\> Security Groups \>\> Create Security Group  \>\>  Security Group name: **APP-SG** \>\> Description: **APP-SG** \>\> VPC: **3-tier VPC** \>\> **Inbound rules** \>\> **Add rule** \>\> Type: Custom TCP \>\> Port: 9051 \>\> Source Type: custom \>\> Source: **ALB-SG** \>\> Create Security Group.


  **DB-SG:** 

  Go to VPC \>\> Security Groups \>\> Create Security Group  \>\>  Security Group name: **DB-SG** \>\> Description: **DB-SG** \>\> VPC: **3-tier VPC** \>\> **Inbound rules** \>\> **Add rule** \>\> Type: MYSQL/Aurora \>\> Source Type: custom \>\> Source: **APP-SG** \>\> Create Security Group.


  **SSM-SG:**

  Go to VPC \>\> Security Groups \>\> Create Security Group  \>\>  Security Group name: **SSM-SG** \>\> Description: **SSM-SG** \>\> VPC: **3-tier VPC** \>\> **Inbound rules** \>\> **Add rule** \>\> Type: HTTPS \>\> Source Type: custom \>\> Source: **APP-SG** \>\> Create Security Group.



# IAM Role Creation
 Creating Role for SSM.


  Go to IAM \>\> Roles \>\> Create Role \>\> Trusted entity type: AWS service \>\> Service or use case: EC2 \>\> Use case: EC2 \>\> Next \>\> Permission Policies: **AmazonSSMManagedInstanceCore** \>\> Next \>\> Role Name: **EC2-SSM-Role** \>\> Create Role.


  


# SSM Endpoints Creation: 
Creating VPC endpoints for SSM. This allows Session manager without ssh. Creating 3 Endpoints for these services: ssm, ssmmessages, ec2messages


  **ssm-Endpoint:**

  Go to VPC \>\> Endpoints \>\> Create Endpoint \>\> Name: **ssm-Endpoint** \>\> Type: AWS services \>\> Service Region \>\> Enable Cross Region endpoint: **Keep it Disabled** \>\> Services: Search for ssm, that it will show like this:  
  Service Name \= com.amazonaws.us-east-1.ssm \>\> Select that service \>\> VPC: **3-tier VPC** \>\> Additional settings \>\> Private DNS name \>\> Enable private DNS name: Enable \>\> DNS record IP type: IPv4 \>\> Subnets \>\> Under Availability Zone \>\> Select the checkbox near **us-east-1a** and **us-east-1b** \>\> Under subnet ID \>\> for us-east-1a , select **Private-App-subnet-A** \>\> for us-east-1b, select **Private-App-subnet-B** \>\> Scroll down a bit \>\> IP address type: IPv4 \>\> Security Groups \>\> Select check box for **SSM-SG** \>\> Policy: Full Access \>\> Create Endpoint.


  

  **ssmmessages-Endpoint:**

  Go to VPC \>\> Endpoints \>\> Create Endpoint \>\> Name: **ssmmessages-Endpoint** \>\> Type: AWS services \>\> Service Region \>\> Enable Cross Region endpoint: **Keep it Disabled** \>\> Services: Search for ssmmessages, that it will show like this:  
  Service Name \= com.amazonaws.us-east-1.ssmmessages \>\> Select that service \>\> VPC: **3-tier VPC** \>\> Additional settings \>\> Private DNS name \>\> Enable private DNS name: Enable \>\> DNS record IP type: IPv4 \>\> Subnets \>\> Under Availability Zone \>\> Select the checkbox near **us-east-1a** and **us-east-1b** \>\> Under subnet ID \>\> for us-east-1a , select **Private-App-subnet-A** \>\> for us-east-1b, select **Private-App-subnet-B** \>\> Scroll down a bit \>\> IP address type: IPv4 \>\> Security Groups \>\> Select check box for **SSM-SG** \>\> Policy: Full Access \>\> Create Endpoint.


  

  **ec2messages-Endpoint:**

  Go to VPC \>\> Endpoints \>\> Create Endpoint \>\> Name: **ec2messages-Endpoint** \>\> Type: AWS services \>\> Service Region \>\> Enable Cross Region endpoint: **Keep it Disabled** \>\> Services: Search for ec2messages, that it will show like this:  
  Service Name \= com.amazonaws.us-east-1.ec2messages \>\> Select that service \>\> VPC: **3-tier VPC** \>\> Additional settings \>\> Private DNS name \>\> Enable private DNS name: Enable \>\> DNS record IP type: IPv4 \>\> Subnets \>\> Under Availability Zone \>\> Select the checkbox near **us-east-1a** and **us-east-1b** \>\> Under subnet ID \>\> for us-east-1a , select **Private-App-subnet-A** \>\> for us-east-1b, select **Private-App-subnet-B** \>\> Scroll down a bit \>\> IP address type: IPv4 \>\> Security Groups \>\> Select check box for **SSM-SG** \>\> Policy: Full Access \>\> Create Endpoint.


  
<img width="2430" height="1174" alt="Screenshot 2026-06-13 214651" src="https://github.com/user-attachments/assets/5c50616a-e7c1-46b9-9be0-b9f761208991" />


# Database Subnet Group Creation: 
Go to Aurora and RDS \>\> Subnet groups \>\> Create DB subnet group \>\> Name: **database-subnet-group** \>\> Description: **3tier-database-subnet-group** \>\> VPC: **3-tier VPC** \>\> Add subnets \>\> Subnets \>\> Select subnets from drop down: "**Private-Db-subnet-A**", "**Private-Db-subnet-B**" \>\> Create.


  **Note:** Although the database is deployed as a Single-AZ instance in us-east-1a, the DB subnet group includes both Private-Db-subnet-A and Private-Db-subnet-B.

  This follows AWS best practices and allows future migration to Multi-AZ deployments without redesigning the network.



# Amazon RDS MySQL Creation: 
Go to Aurora and RDS \>\> Databases \>\> Create Database \>\> Full configuration \>\> Engine type: MySQL \>\> Choose a database creation method: Full configuration \>\> Templates: Free tier    (Free tier gives only one database server with single AZ for free. If you select Dev/Test template or Production template option, it gives 3 options as you can see in the below screenshot:

<img width="1278" height="624" alt="Screenshot 2026-06-13 222110" src="https://github.com/user-attachments/assets/7c3caed8-0822-44f6-acc8-0a2d8951ddac" />

(Usually in company we need to select either production template or Dev/Test template, so that we can select database instances according to our need)

\>\> Currently I will select **Free tier Template** \>\> Deployment option: Single-AZ DB instance deployment (1 instance) \>\> Engine Version: MySQL 8.4.8 \>\> DB instance identifier: **usernotes** \>\> Credentials Settings \>\> Master username: admin \>\> Credentials management: Self managed \>\> Master password: ASoYRxsAI9snyjZZWjG6 \>\> Confirm master password: ASoYRxsAI9snyjZZWjG6 \>\> Database authentication options: Password authentication \>\> **Instance configuration** \>\> DB instance class \>\> Select **Burstable classes (includes t classes)** \>\> Instance type: db.t3.micro \>\> Storage type: General Purpose SSD (gp3) \>\> Allocated storage: 20 GiB \>\> Connectivity \>\> Compute resource \>\> Select **Don’t connect to an EC2 compute resource** \>\> VPC: **3-tier VPC** \>\> DB subnet group: **database-subnet-group** \>\> Public access: No \>\> VPC security group (firewall): Choose Existing \>\> Existing VPC security groups: Select **DB-SG** \>\> Availability Zone: us-east-1a \>\> Create database. (Takes few minutes to create)

**Master username**: admin  
**Master password**: ASoYRxsAI9snyjZZWjG6  
**Endpoint**: usernotes.cu9e4agaow6j.us-east-1.rds.amazonaws.com

# Read Replica database (optional): 
Not created in this implementation.
  In production environments, a read replica can be created in another Availability Zone to offload read traffic from the primary database. 



# AWS Secrets Manager Creation
 In production, we don't hardcode the database password in application. We use a secret manager to store secrets securely.


  Go to Secret manager \>\> Store a new secret \>\> Secret Type: Credentials for Amazon RDS database \>\> Credentials \>\> Username: admin \>\> Password: ASoYRxsAI9snyjZZWjG6 \>\> Encryption key: aws/secretsmanager \>\> Database: Select **usernotes**  \>\> Next \>\> Secret name: **usernotes-rds-secret** \>\> Next \>\> Configure automatic rotation: **Keep it disabled** \>\> Next \>\> Scroll down \>\> Store.


  Once secret is created, copy the ARN of it: 
  **arn:aws:secretsmanager:us-east-1:544917027663:secret:usernotes-rds-secret-XGn3hP**


  

  **Modify IAM role to add Secret manager permission**:

  Go to IAM \>\> Roles \>\> Select The role: **EC2-SSM-Role** \>\> Add Permissions \>\> Create inline policy \>\> Json \>\> Paste this:

```bash
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "secretsmanager:GetSecretValue"
      ],
      "Resource": "arn:aws:secretsmanager:us-east-1:544917027663:secret:usernotes-rds-secret-XGn3hP"
    }
  ]
}
```

  \>\> Next \>\> Policy Name: **SecretsManagerRead** \>\> Create policy.


  


# Creating Application EC2 Instance: 
Here we will add all the packages and applications and then we will create AMI for the launch template.


  Go to EC2 \>\> Launch instance \>\> Name: **Application EC2** \>\> AMI: Amazon linux 2023 \>\> Instance type: t3.micro \>\> Key pair name: Proceed without a key pair \>\> Network settings \>\> Edit \>\> VPC: **3-tier VPC** \>\> Subnet: **Private-App-subnet-A** \>\> Firewall (security groups): Select existing Security Group: **APP-SG** \>\> Advanced details \>\> IAM instance profile: **EC2-SSM-Role** \>\> Launch instance.


  **Login to instance using ssm:** Select the ec2 instance you created \>\> connect \>\> SSM Session Manager \>\> Connect.


  Install following packages:

```bash 
sudo dnf update -y
sudo dnf install mariadb105 -y   
sudo dnf install git python3 python3-pip -y  
sudo pip3 install flask pymysql boto3
```

  Connect to RDS:

```bash
mysql -h usernotes.cu9e4agaow6j.us-east-1.rds.amazonaws.com -u admin -p
```

  (**Syntax**: mysql \-h \<database-host-name\> \-u \<database-username\> \-p)

  Once you enter the above command, it asks for the database password, you can paste the password and enter it.

  Password: ASoYRxsAI9snyjZZWjG6


  

  Create database: (Run below commands)

```bash
CREATE DATABASE usernotes;  
USE usernotes;
```

  Create table: (Run below command at one)

```bash
CREATE TABLE notes (
  id INT AUTO\_INCREMENT PRIMARY KEY,
  username VARCHAR(100),
  note TEXT,
  created\_at TIMESTAMP DEFAULT CURRENT\_TIMESTAMP
);
```

```bash
exit
```
  After exiting from the database, follow the next steps below.



# Running the Application 

```bash
sudo su ec2-user  
cd  
git clone https://github.com/nagaraj602/3-tier-Architecture-python-Application.git  
cd 3-tier-Architecture-python-Application  
pip3 install -r requirements.txt  
sudo python3 app.py
```


<img width="1388" height="296" alt="Screenshot 2026-06-13 235942" src="https://github.com/user-attachments/assets/da96aea0-340c-452b-a415-144f90b15942" />



  Currently you cannot access the application via browser as the application will be running in a private subnet. It will work when we connect to the ALB.  
    
  To make the application run during boot, we will create service file:  
  
```bash
sudo vi /etc/systemd/system/usernotes.service
```

  
```bash
[Unit]
Description=User Notes Flask Application
After=network.target

[Service]
User=ec2-user
WorkingDirectory=/home/ec2-user/app
ExecStart=/usr/bin/python3 /home/ec2-user/app/app.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
```

  

- :wq  
```bash
sudo systemctl daemon-reload  
sudo systemctl enable usernotes  
sudo systemctl start usernotes
```

  


# Create AMI: 
Go to Ec2 \>\> Select the private instance you created: **Application Ec2** \>\> Actions \>\> Image and templates \>\> Create image \>\> Image name: **3tier-app-ami** \>\> Create image.


  


# Create Launch Template 
Go to EC2 \>\> Launch templates \>\> Create launch template \>\> Launch template name: **3-tier-launch-template** \>\> AMI \>\> My AMIs \>\> **3tier-app-ami** \>\> Instance type: t3.micro \>\> Key pair: Don't include in launch template \>\> Security Group: Select Existing Security Group \>\> **APP-SG** \>\> Advanced details \>\> IAM instance profile: **EC2-SSM-Role** \>\> Create Launch templates.


  


# Create Target Group 
Go to EC2 \>\> Target groups \>\> Create target group \>\> Target type: Instances \>\> Target group name: **3-tier-target-group** \>\> Protocol: HTTP \>\> Port: 9051 \>\> IP address type: IPv4 \>\> VPC: **3-tier VPC** \>\> Protocol version: HTTP1 \>\> Health checks \>\> Health check protocol: HTTP \>\>  Health check path: / \>\> Next \>\> Scroll down \>\> Next \>\> Create target group.


  


# Create Application Load Balancer (ALB)
 Go to EC2 \>\> Load balancers \>\> Create load balancer \>\> Application Load balancer \>\> Create \>\> Load balancer name: **3-tier-ALB** \>\> Scheme: Internet-facing \>\> Load balancer IP address type: IPv4 \>\> VPC: **3-tier VPC** \>\> Availability Zones and subnets: 

  us-east-1a : Public-Web-subnet-A

  us-east-1b : Public-Web-subnet-B  

  \>\> Security Group: **ALB-SG** \>\> Listeners and routing \>\> Protocol: HTTP \>\> Port: 80 \>\> Routing action: Forward to target groups \>\> Forward to target group \>\> Target group: **3-tier-target-group** \>\> Weight: 1 \>\> Percent: 100% \>\> Scroll down \>\> Create load balancer.


  Load balancer URL: [http://3-tier-ALB-1098534071.us-east-1.elb.amazonaws.com](http://3-tier-ALB-1098534071.us-east-1.elb.amazonaws.com)  



# Create Auto Scaling Group:  
Go to EC2 \>\> Scroll down side bar \>\> Auto scaling groups \>\> Create Auto scaling group \>\> Auto Scaling group name: **3-tier-ASG** \>\> Launch Template: **3-tier-launch-template** \>\> Version: Latest \>\> Next \>\> VPC: **3-tier VPC** \>\> Availability Zones and subnets: **Private-App-subnet-A**  and **Private-App-subnet-B** \>\> Next \>\> Select Load balancing options: Attach to an existing load balancer \>\> Select the load balancers to attach: **3-tier-target-group** \>\> Select VPC Lattice service to attach: No VPC Lattice service \>\> Health checks \>\> Additional health check types \- optional \>\> Turn on Elastic Load Balancing health checks: Enable \>\> Health check grace period: 300 Seconds \>\> Next \>\> Desired capacity: 2 \>\> Scaling \>\> Min desired capacity: 2 \>\> Max desired capacity: 4 \>\> Automatic scaling: Target tracking scaling policy \>\> Scaling policy name: **Target Tracking Policy** \>\> Metric type: Application Load balancer request count per target \>\> Target group: 3-tier-target-group \>\> Target value: 60 \>\> Instance warmup: 300 Seconds \>\> Scroll down \>\> Next \>\> Next \>\> Next \>\> Create Auto Scaling group.


  

# Health check in target group
Go to Target groups and check if you see healthy instances. If not, find the root cause.


  

# Cloudfront Setup
Go to cloudfront \>\> Create distribution \>\> Choose plan: Free \>\> Next \>\> Distribution name: **3-tier-Cloudfront** \>\> Distribution type: Single website or app \>\> Next \>\> Origin type: Elastic Load balancer \>\> Elastic Load Balancing origin \>\> Browse load balancer: **3-tier-ALB** \>\> Choose \>\> Settings \>\> Origin settings \>\> Customize settings \>\> Protocol: HTTP only \>\> HTTP port: 80 \>\>  Scroll down \>\> Next \>\> Enabled security \>\> Web Application Firewall (WAF) \>\> Use monitor mode: Enable \>\> Rate limiting: Enable \>\> Next \>\> Create distribution.  (WAF is enabled by default here)


  URL: [http://d20b1uc1sfqpos.cloudfront.net](http://d20b1uc1sfqpos.cloudfront.net)  


<img width="1326" height="806" alt="Screenshot 2026-06-14 151935" src="https://github.com/user-attachments/assets/43e7e86b-ebd0-4d29-a97d-9265145e0b6c" />
<img width="1370" height="1188" alt="Screenshot 2026-06-14 152003" src="https://github.com/user-attachments/assets/cc403328-a4d3-4587-9327-3b425a588b12" />
<img width="1374" height="1138" alt="Screenshot 2026-06-14 152045" src="https://github.com/user-attachments/assets/d9408f8a-d30e-4009-9d62-a3ee9c407ebf" />
<img width="1324" height="1176" alt="Screenshot 2026-06-14 152104" src="https://github.com/user-attachments/assets/0712c351-721b-4cfe-bd48-d0dffc6783a9" />
<img width="1346" height="1230" alt="Screenshot 2026-06-14 152126" src="https://github.com/user-attachments/assets/7eda3789-5e47-40fc-8ec2-d14c85412623" />
<img width="1332" height="1346" alt="Screenshot 2026-06-14 152144" src="https://github.com/user-attachments/assets/c9bd28a0-744c-41e5-bd7a-1bf89762a7e3" />





 

