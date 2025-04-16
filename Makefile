.PHONY: apply destroy kubeconfig helm teleport agents destroy-sans-ip

apply:
	cd terraform && terraform init && terraform apply -auto-approve

destroy:
	cd terraform && terraform destroy -auto-approve

destroy-sans-ip:
	cd terraform && terraform destroy \
		-target=azurerm_kubernetes_cluster.teleport \
		-target=azurerm_linux_virtual_machine.ubuntu_client \
		-target=azurerm_windows_virtual_machine.ad_server \
		-auto-approve

kubeconfig:
	az aks get-credentials --resource-group rg-teleport-efrei --name aks-teleport

teleport:
	@echo "Installing Teleport via Helm..."
	helm repo add teleport https://charts.releases.teleport.dev || true
	helm repo update
	helm upgrade --install teleport teleport/teleport-cluster \
		--namespace teleport --create-namespace \
		-f helm/values.yaml

agents:
	kubectl apply -f k8s/teleport-agents.yaml

apply-clients:
	cd terraform/clients && terraform init && terraform apply -auto-approve

destroy-clients:
	cd terraform/clients && terraform destroy -auto-approve
