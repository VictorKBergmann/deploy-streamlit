variable "aws_region" {
  description = "Região da AWS para deploy"
  type        = string
  default     = "us-east-1" 
}

variable "key_pair_name" {
  description = "Nome da Key Pair SSH registrada na AWS"
  type        = string
  default     = "streamlit-deploy" # O nome que você criou no console
}