# resource "aws_cognito_user_pool" "user_pool" {
#   name = "user-pool"

#   username_attributes      = ["email"]
#   auto_verified_attributes = ["email"]
#   password_policy {
#     minimum_length = 6
#   }

#   verification_message_template {
#     default_email_option = "CONFIRM_WITH_CODE"
#     email_subject        = "[Cloud7] Account Confirmation"
#     email_message        = "Your confirmation code is {####}"
#   }

#   schema {
#     attribute_data_type      = "String"
#     developer_only_attribute = false
#     mutable                  = true
#     name                     = "email"
#     required                 = true

#     string_attribute_constraints {
#       min_length = 1
#       max_length = 256
#     }
#   }
# }

# resource "aws_cognito_user_pool_client" "client" {
#   name                                 = "cognito-client"
#   user_pool_id                         = aws_cognito_user_pool.user_pool.id
#   callback_urls                        = ["https://cloud7.solutions/login/oauth2/code/oidc"]
#   generate_secret                      = true
#   allowed_oauth_flows_user_pool_client = true
#   allowed_oauth_flows                  = ["code"]
#   allowed_oauth_scopes                 = ["email", "openid", "profile"]
#   refresh_token_validity               = 90

#   supported_identity_providers = ["COGNITO"]
# }

# resource "aws_cognito_user_pool_domain" "cognito-domain" {
#   domain       = var.service_name
#   user_pool_id = aws_cognito_user_pool.user_pool.id
# }
