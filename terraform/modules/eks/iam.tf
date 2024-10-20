##################
#AWS EKS IAM ROLE
##################

resource "aws_iam_role" "AWSRoleForEKS" {
  name               = "AWSRoleEKS-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.this_eks.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.AWSRoleForEKS.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.AWSRoleForEKS.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKSCloudWatch" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  role       = aws_iam_role.AWSRoleForEKS.name
}

###################
#EKS Node Group IAM
###################

resource "aws_iam_role" "AWSRoleForEKSNodeGroup" {
  name               = "AWSRoleEKSNodeGroup-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.this_eks_ng.json
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.AWSRoleForEKSNodeGroup.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.AWSRoleForEKSNodeGroup.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.AWSRoleForEKSNodeGroup.name
}


#######################
#EKS OIDC Configuration
#######################

resource "aws_iam_openid_connect_provider" "AWSIdentityOICD" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.this_eks.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.this.identity.0.oidc.0.issuer
}
