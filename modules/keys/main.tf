# ---------------------------------------------------------------------------------------------------------------------
#  CREATE SSH KEYS
# ---------------------------------------------------------------------------------------------------------------------

resource "tls_private_key" "id" {
  algorithm = "RSA"
  rsa_bits  = "4096"
}

# Store the id private key in a file.
resource "local_file" "id_rsa" {
  depends_on        = [tls_private_key.id]
  filename          = "modules/keys/id_rsa"
  file_permission   = "0600"
  sensitive_content = tls_private_key.id.private_key_pem
}

# Store the id public key in a file.
resource "local_file" "id_rsa_pub" {
  content    = tls_private_key.id.public_key_openssh
  filename   = "modules/keys/id_rsa.pub"
  depends_on = [tls_private_key.id]
}