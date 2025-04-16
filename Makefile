.PHONY: apply destroy kubeconfig helm teleport agents

check-login:
	@az account show > /dev/null 2>&1 || (echo "❌ Azure CLI not logged in. Run 'az login' first." && exit 1)

apply: check-login
	cd terraform && terraform init && terraform apply -auto-approve

destroy: check-login
	cd terraform && terraform destroy -auto-approve

kubeconfig:
	az aks get-credentials --resource-group rg-teleport-efrei --name aks-teleport

teleport: check-login
	@echo "Installing Teleport via Helm..."
	helm repo add teleport https://charts.releases.teleport.dev
	helm repo update
	helm upgrade --install teleport teleport/teleport-cluster \
  --namespace teleport --create-namespace \
  -f helm/values.yaml

agents: check-login
	kubectl apply -n teleport -f k8s/teleport-agents.yaml

apply-clients: check-login
	cd terraform/clients && terraform init && terraform apply -auto-approve

destroy-clients: check-login
	cd terraform/clients && terraform destroy -auto-approve
