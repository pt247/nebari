resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  name       = "cert-manager"
  namespace  = var.namespace_name
  version    = var.chart_version

  # TODO Add a node selector
  set {
    name  = "installCRDs"
    value = "true"
  }

  values = concat([file("${path.module}/values.yaml")])

}


resource "kubernetes_manifest" "clusterissuer_letsencrypt_staging" {
  manifest = yamldecode(<<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
 name: letsencrypt-staging
spec:
 acme:
   email: ptiwari@quansight.com
   server: https://acme-staging-v02.api.letsencrypt.org/directory
   privateKeySecretRef:
     name: letsencrypt-staging
   solvers:
     - http01:
         # The ingressClass used to create the necessary ingress routes
         ingress:
           class: traefik
YAML
  )
}


resource "kubernetes_manifest" "certificate_local_nebari_dev" {
manifest = yamldecode(<<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: letsencrypt-staging
  namespace: dev
spec:
  secretName: local.quansight-dev-tls
  issuerRef:
    name: letsencrypt-staging
  dnsNames:
  - local.nebari.dev
YAML
)
}
