INFRASTRUCTURE AND APPLICATION DEPLOYMENT GUIDE
================================================

This guide outlines the steps to deploy infrastructure on AWS using Terraform and deploy a simple NGINX web server application on an Amazon Elastic Kubernetes Service (EKS) cluster.

TERRAFORM FOLDER

Infrastructure Deployment
-------------------------

Prerequisites

1. AWS CLI installed and configured with appropriate credentials.
2. Terraform installed locally.

Steps

1. Navigate to the terraform folder.
2. Run terraform init to initialize the Terraform configuration.
3. Run terraform plan to review the execution plan.
4. Run terraform apply to create the VPC, subnets, internet gateway, route tables, NAT gateway, etc.

KUBERNETES FOLDER

Load Balancer Configuration
---------------------------

Prerequisites

1. Ensure the AWS Load Balancer Controller is deployed in the EKS cluster.

Steps

1. Run aws-loadbalancer-controller.sh to grant permission for the load balancer to create resources.
2. Apply the deploy.yaml under the ingress-nginx folder to create the Elastic Load Balancer (ELB).

Application Deployment
----------------------

Prerequisites

1. Ensure the EKS cluster is up and running.
2. NGINX Ingress controller deployed in the cluster.

Steps

1. Navigate to the kubernetes folder.
2. Apply the Kubernetes manifests in the following order:
3. namespace.yaml to create a Kubernetes namespace.
4. rbac.yaml to create RBAC roles and bindings.
5. service.yaml to create a Kubernetes Service.
6. deployment.yaml to deploy the NGINX web server application.
7. ingress.yaml to configure the Ingress resource for the application.

SUMMARY

This guide provides step-by-step instructions for deploying infrastructure on AWS using Terraform, configuring the load balancer, and deploying a simple NGINX web server application on an EKS cluster.
