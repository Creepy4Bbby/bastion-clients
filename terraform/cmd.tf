# run multiple commands in a single local-exec provisioner
resource "null_resource" "example" {
  triggers = {
    always_run = "${timestamp()}"
  }

  depends_on = [ azurerm_kubernetes_cluster.teleport ]

  provisioner "local-exec" {
    command = "mkdir -p ~/.azure_k8s && echo \"${azurerm_kubernetes_cluster.teleport.kube_config_raw}\" > ~/.azure_k8s/k8s.conf"
  }
}
