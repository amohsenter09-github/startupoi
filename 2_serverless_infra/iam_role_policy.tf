
#########################################authenticated###################################
resource "aws_iam_role" "authenticated" {
  name = "cognito_authenticated"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "cognito-identity.amazonaws.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.dev_startupoi_cognito.id}"
        },
        "ForAnyValue:StringLike": {
          "cognito-identity.amazonaws.com:amr": "authenticated"
        }
      }
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "authenticated" {
  name = "authenticated_policy"
  role = aws_iam_role.authenticated.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_cognito_identity_pool_roles_attachment" "authenticated" {
  identity_pool_id = aws_cognito_identity_pool.dev_startupoi_cognito.id

  role_mapping {
    identity_provider         = "graph.facebook.com"
    ambiguous_role_resolution = "AuthenticatedRole"
    type                      = "Rules"

    mapping_rule {
      claim      = "isAdmin"
      match_type = "Equals"
      role_arn   = aws_iam_role.authenticated.arn
      value      = "paid"
    }
  }

  roles = {
    "authenticated" = aws_iam_role.authenticated.arn
  }
}


#########################################unauthenticated###################################
# resource "aws_iam_role" "unauthenticated" {
#   name = "cognito_unauthenticated"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Principal": {
#         "Federated": "cognito-identity.amazonaws.com"
#       },
#       "Action": "sts:AssumeRoleWithWebIdentity",
#       "Condition": {
#         "StringEquals": {
#           "cognito-identity.amazonaws.com:aud": "${aws_cognito_identity_pool.dev_startupoi_cognito.id}"
#         },
#         "ForAnyValue:StringLike": {
#           "cognito-identity.amazonaws.com:amr": "unauthenticated"
#         }
#       }
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy" "unauthenticated" {
#   name = "authenticated_policy"
#   role = aws_iam_role.authenticated.id

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "mobileanalytics:PutEvents",
#         "cognito-sync:*"
#       ],
#       "Resource": [
#         "*"
#       ]
#     }
#   ]
# }
# EOF
# }

# resource "aws_cognito_identity_pool_roles_attachment" "unauthenticated" {
#   identity_pool_id = aws_cognito_identity_pool.dev_startupoi_cognito.id

#   role_mapping {
#     identity_provider         = "graph.facebook.com"
#     ambiguous_role_resolution = "AuthenticatedRole Deny"
#     type                      = "Rules"

#    mapping_rule {
#       claim      = "isAdmin"
#       match_type = "Equals"
#       role_arn   = aws_iam_role.authenticated.arn
#       value      = "paid"
#     }
  
#   }

#   roles = {
#     "unauthenticated" = aws_iam_role.unauthenticated.arn
#   }
# }


