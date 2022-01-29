resource "aws_cognito_user_pool" "dev_startupoi" {
  auto_verified_attributes = [
    "email",
  ]


  mfa_configuration = "OFF"
  name              = "dev_startupoi-cognito"
  tags              = {}
  tags_all          = {}
  username_attributes = [
    "email",
  ]

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
  }

  admin_create_user_config {
    allow_admin_create_user_only = false

    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}. "
      email_subject = "Your temporary password"
      sms_message   = "Your username is {username} and temporary password is {####}. "
    }
  }

  email_configuration {
    email_sending_account = "DEVELOPER"
    source_arn            = "arn:aws:ses:us-west-2:159231561593:identity/noreply@startupoi.com"
  }

  lambda_config {
    pre_sign_up = aws_lambda_function.main[0].arn
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = false
    require_numbers                  = false
    require_symbols                  = false
    require_uppercase                = false
    temporary_password_validity_days = 7
  }

  schema {
    attribute_data_type      = "Number"
    developer_only_attribute = false
    mutable                  = false
    name                     = "change_password"
    required                 = false

    number_attribute_constraints {
      max_value = "1"
      min_value = "0"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "facebook_user_id"
    required                 = false

    string_attribute_constraints {
      max_length = "256"
      min_length = "1"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "tech_test_ref"
    required                 = false

    string_attribute_constraints {
      max_length = "256"
      min_length = "1"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = false
    name                     = "temporary_password"
    required                 = false

    string_attribute_constraints {
      max_length = "256"
      min_length = "1"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "email"
    required                 = true

    string_attribute_constraints {
      max_length = "2048"
      min_length = "0"
    }
  }
  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "tech_test_id"
    required                 = false

    string_attribute_constraints {
      max_length = "256"
      min_length = "1"
    }
  }

  username_configuration {
    case_sensitive = false
  }

  verification_message_template {
    default_email_option  = "CONFIRM_WITH_LINK"
    email_message         = "Your verification code is {####}. "
    email_message_by_link = <<-EOT
            <div style="padding: 0 10px 0 10px; max-width: 400px; margin: auto;">
                <div>
                    <img src="https://startupoi-dev.s3.eu-west-1.amazonaws.com/email/logo_name.png" alt="" width="180"
                        height="58" />
                </div>
                <div style="padding: 0 10px 0 10px;">
                    <p style="font-size: 1.4em">Welcome to startup oi!</p>
                    <img src="https://startupoi-dev.s3.eu-west-1.amazonaws.com/email/artboard.png" alt="" width="300"
                        height="242" style="display: block; margin: 0 auto;" />
                    <p style="text-align: center; color: #121212; font-size: 1.3em; padding: 0 70px 0 70px"> Verify your email
                        address to complete registration </p>
                    <p style="text-align: center; color: #3D3A45; font-size: 1.1em; padding: 0 20px 0 20px"> Thanks for your
                        interest in joining startup oi! To complete your registration, we need to verify your email address. </p>
                    <div style="margin-top: 40px;">
                        {## <img alt="verify email"
                            src="https://startupoi-dev.s3.eu-west-1.amazonaws.com/email/verify_email_button.png" width="400"
                            height="54" style="display: block; margin: 0 auto;" /> ##}
                    </div>
                </div>
            </div>
        EOT
    email_subject         = "Your verification code"
    email_subject_by_link = "Your verification link"
    sms_message           = "Your verification code is {####}. "
  }
}

resource "aws_cognito_user_pool_domain" "dev_startupoi" {
  domain          = "dev-startupoi"
  user_pool_id    = aws_cognito_user_pool.dev_startupoi.id
}

resource "aws_cognito_user_pool_client" "client" {
  name         = "startupoi-mobile"
  user_pool_id = "${aws_cognito_user_pool.dev_startupoi.id}" # the cognito pool id created in step 1

  generate_secret                      = true
  explicit_auth_flows                  = ["ADMIN_NO_SRP_AUTH", "USER_PASSWORD_AUTH"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  supported_identity_providers         = ["COGNITO"]
  allowed_oauth_scopes                 = ["aws.cognito.signin.user.admin", "openid", "profile", "email"]

    callback_urls = ["https://example.com/callback"  ]
    logout_urls   = ["https://example.com/signout"]
}

resource "aws_cognito_identity_provider" "facebook_provider" {
  user_pool_id  = aws_cognito_user_pool.dev_startupoi.id
  provider_name = "Facebook"
  provider_type = "Facebook"

#This information needs to be provided by the client directly or retrieved from secret manager.
  provider_details = {
    authorize_scopes = "email,public_profile"
    client_id        = "your client_id" ## Best practice to retrieve these value from secrets 
    client_secret    = "your client_secret" ## Best practice to retrieve these value from secrets
  }

  attribute_mapping = {
    email    = "email"
    
  }
}

  resource "aws_cognito_identity_pool" "dev_startupoi_cognito" {
  identity_pool_name               = "dev_startupoi-cognito"
  allow_unauthenticated_identities =  false
   supported_login_providers = {
    "graph.facebook.com" = "7346241598935555"
  }
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id 
    provider_name           = "cognito-idp.eu-west-1.amazonaws.com/${aws_cognito_user_pool.dev_startupoi.id}"
    server_side_token_check = false
  }
  }
