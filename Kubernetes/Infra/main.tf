module "network" {
    source = "./modules/network"
    env = "PROD"
    project_name = "ECOMMERCE"
    region = "MUMBAI"
    vpc_cidr = "10.0.0.0/24"
    pub_sub_cidr = ["10.0.0.0/26", "10.0.0.64/26"]
    pvt_sub_cidr = ["10.0.0.128/26", "10.0.0.192/26"]
    availability_zone = ["ap-south-1a","ap-south-1b"]

}
module "eks" {
  source = "./modules/eks"
  subnet_id = module.network.pvt_subnets[*]
  node_group_name = "test-nodegroup"
  env = "PROD"
  project_name = "ECOMMERCE"
  region = "MUMBAI"
}

