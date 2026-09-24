variable "mysql_database" {
  description = "Banco de dados da aplicacao"
  type        = string
  default     = "mecaniqa"
}

variable "mysql_user" {
  description = "Usuario da aplicacao no MySQL"
  type        = string
  default     = "mecaniqa_user"
}

variable "mysql_password" {
  description = "Senha do usuario da aplicacao"
  type        = string
  default     = "password321"
  sensitive   = true
}

variable "mysql_root_password" {
  description = "Senha do usuario root do MySQL"
  type        = string
  default     = "dbpassword321"
  sensitive   = true
}
