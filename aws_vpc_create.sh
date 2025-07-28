#!/bin/bash


# This script creates a new VPC in AWS using the AWS CLI.

###########################

# Description: Create a new VPC in AWS
# - Creates a VPC with a specified CIDR block
# - Create a public subnet
# - Create a private subnet
# - Create an internet gateway and attach it to the VPC
# - Create a route table and associate it with the public subnet
# - Make sure aws cli is configured with the correct credentials and region
# - Requires AWS CLI installed
###########################

# Variables
VPC_CIDR="10.10.10.10/25"
PUBLIC_SUBNET_CIDR="10.10.10.0/26"
PRIVATE_SUBNET_CIDR="10.10.10.64/26"
REGION="us-west-2"
# Create VPC
VPC_ID=$(aws ec2 create-vpc --cidr-block $VPC_CIDR --region $REGION --query 'Vpc.VpcId' --output text)
echo "Created VPC with ID: $VPC_ID"

# Enable DNS support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-support
aws ec2 modify-vpc-attribute --vpc-id $VPC_ID --enable-dns-hostnames    
echo "Enabled DNS support and hostnames for VPC: $VPC_ID"
# Create public subnet
PUBLIC_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID
    --cidr-block $PUBLIC_SUBNET_CIDR --availability-zone ${REGION}a --query 'Subnet.SubnetId' --output text)    
echo "Created public subnet with ID: $PUBLIC_SUBNET_ID"

# Create private subnet
PRIVATE_SUBNET_ID=$(aws ec2 create-subnet --vpc-id $VPC_ID
    --cidr-block $PRIVATE_SUBNET_CIDR --availability-zone ${REGION}a --query 'Subnet.SubnetId' --output text)
echo "Created private subnet with ID: $PRIVATE_SUBNET_ID"   
# Create internet gateway
INTERNET_GATEWAY_ID=$(aws ec2 create-internet-gateway --query 'InternetGateway.InternetGatewayId' --output text)
aws ec2 attach-internet-gateway --vpc-id $VPC_ID --internet-gateway-id $INTERNET_GATEWAY_ID
echo
    "Created and attached internet gateway with ID: $INTERNET_GATEWAY_ID"               
# Create route table for public subnet
ROUTE_TABLE_ID=$(aws ec2 create-route-table --vpc-id $VPC_ID --query 'RouteTable.RouteTableId' --output text)
aws ec2 create-route --route-table-id $ROUTE_TABLE_ID --destination-cidr-block 0.0.0.0/0 --gateway-id $INTERNET_GATEWAY_ID      
aws ec2 associate-route-table --subnet-id $PUBLIC_SUBNET_ID --route-table-id $ROUTE_TABLE_ID
echo "Created route table with ID: $ROUTE_TABLE_ID and associated it with public subnet
with ID: $PUBLIC_SUBNET_ID"
# Output the details
echo "VPC ID: $VPC_ID"
echo "Public Subnet ID: $PUBLIC_SUBNET_ID"
echo "Private Subnet ID: $PRIVATE_SUBNET_ID"            
echo "Internet Gateway ID: $INTERNET_GATEWAY_ID"                
echo "Route Table ID: $ROUTE_TABLE_ID"
# End of script
echo "VPC creation script completed successfully."
exit 0
# Note: Make sure to clean up resources if this script is run multiple times to avoid conflicts 

# and unnecessary charges.