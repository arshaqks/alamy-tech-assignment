#!/bin/bash

# Set variables
CLUSTER_NAME="PROD-ECOMMERCE-MUMBAI-EKS-CLUSTER"
REGION="ap-south-1"
POLICY_NAME="AWSLoadBalancerControllerIAMPolicy"
POLICY_DOCUMENT_URL="https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/v2.5.4/docs/install/iam_policy.json"
OIDC_PROVIDER_URL="https://oidc.eks.${REGION}.amazonaws.com/id/${CLUSTER_NAME}"
NAMESPACE="kube-system"
SA_NAME="aws-load-balancer-controller"
ROLE_NAME="AmazonEKSLoadBalancerControllerRole"
POLICY_ARN="arn:aws:iam::142928493353:policy/AWSLoadBalancerControllerIAMPolicy"

# Download IAM policy document
curl -O "$POLICY_DOCUMENT_URL"

# Check if the policy exists
if ! aws iam get-policy --policy-arn "$POLICY_ARN" &> /dev/null; then
  # Create AWS IAM policy
  aws iam create-policy \
    --policy-name "$POLICY_NAME" \
    --policy-document file://iam_policy.json
else
  echo "IAM policy $POLICY_ARN already exists. Skipping creation."
fi

# Check if the OIDC provider is already associated
if ! eksctl utils associate-iam-oidc-provider --region="$REGION" --cluster="$CLUSTER_NAME" --approve &> /dev/null; then
  # Associate IAM OIDC provider
  eksctl utils associate-iam-oidc-provider --region="$REGION" --cluster="$CLUSTER_NAME" --approve
else
  echo "OIDC provider is already associated. Skipping association."
fi

# Check if the IAM service account already exists
if aws eks describe-fargate-profile --cluster-name "$CLUSTER_NAME" --fargate-profile-name "$SA_NAME" --region "$REGION" &> /dev/null; then
  # IAM service account exists
  echo "IAM service account already exists."
else
  # Create IAM service account
  eksctl create iamserviceaccount \
    --cluster="$CLUSTER_NAME" \
    --namespace="$NAMESPACE" \
    --name="$SA_NAME" \
    --role-name="$ROLE_NAME" \
    --attach-policy-arn="$POLICY_ARN" \
    --approve
fi


# Install load balancer controller using Helm
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n "$NAMESPACE" \
  --set clusterName="$CLUSTER_NAME" \
  --set serviceAccount.create=false \
  --set serviceAccount.name="$SA_NAME"


#eksctl get iamserviceaccount --cluster=PROD-ECOMMERCE-MUMBAI-EKS-CLUSTER --namespace=kube-system
