availability_zones                          = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
name_prefix                                 = "dev"
vpc_cidr_block                              = "175.31.0.0/16"
public_subnets_cidrs_per_availability_zone  = ["175.31.15.0/24", "175.31.16.0/24", "175.31.17.0/24"]
private_subnets_cidrs_per_availability_zone = ["175.31.0.0/24", "175.31.2.0/24", "175.31.1.0/24"]
instance_type                               = ["t2.medium", "t2.small"]
database_name                               = "eslasticdb"
rds_username                                = "admin"
rds_password                                = "admin1324##$$"
identifier                                  = "rdsdvdb"

## This the accountmircoservice-app application and its assocaiated env
accountmircoservice-app = "dev-accountmircoservice-app"
accountmircoservice-env = "dev-accountmircoservice-env"

# ## This the filemircoservice-app application and its assocaiated env variables 
filemircoservice-app  = "filemircoservice-app"
filetmircoservice-env = "filetmircoservice-env"


## This the filemircoservice-app application and its assocaiated env variables 
jobmircoservice-app = "jobmircoservice-app"
jobmircoservice-env = "jobmircoservice-env"


## This the statelessdatamircoservice-app application and its assocaiated env variables 
statelessdatamircoservice-app = "statelessdatamircoservice-app"
statelessdatamircoservice-env = "statelessdatamircoservice-env"

