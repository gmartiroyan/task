output "this_eks_endpoint" {
  value = aws_eks_cluster.this.endpoint
}

output "this_eks_ca" {
  value = base64decode(aws_eks_cluster.this.certificate_authority.0.data)
}

output "this_eks_id" {
  value = aws_eks_cluster.this.id
}

output "identity-oidc-issuer" {
  value = aws_eks_cluster.this.identity[0].oidc[0].issuer
}
