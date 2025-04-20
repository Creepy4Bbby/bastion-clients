.PHONY: apply destroy kubeconfig helm teleport agents

check-login:
	@az account show > /dev/null 2>&1 || (echo "❌ Azure CLI not logged in. Run 'az login' first." && exit 1)

plan: check-login
	cd terraform && terraform init && terraform plan
	@echo "Terraform plan completed."

apply: check-login
	cd terraform && terraform apply -auto-approve
	@echo "Terraform apply completed."
	@echo "Waiting for AKS to be ready..."
	@az aks wait --resource-group rg-teleport-efrei --name aks-teleport --created
	@echo "AKS is ready. Waiting for pods to be ready..."

destroy: check-login
	cd terraform && terraform destroy -auto-approve

kubeconfig:
	az aks get-credentials --resource-group rg-teleport-efrei --name teleport-aks

teleport: check-login
	@echo "Installing Teleport via Helm..."
	helm repo add teleport https://charts.releases.teleport.dev
	helm repo update
	helm upgrade --install teleport teleport/teleport-cluster \
  --namespace teleport --create-namespace \
  -f helm/values.yaml
	
	@echo "Teleport installed. Waiting for pods to be ready..."
	# kubectl wait --for=condition=available --timeout=600s -n teleport deployment/teleport
	@echo "Teleport is ready."
	@echo "Teleport is ready. You can access it at https://teleportnew.dhuet.cloud"
	kubectl exec -it -n teleport pod/teleport-auth-699c6d64bb-kvkm9 -- tctl users add admin --roles=editor,auditor,access
	# #  Mettre id du pod auth

teleportupdate:	check-login

	helm upgrade --install teleport teleport/teleport-cluster \
  --namespace teleport --create-namespace \
  -f helm/values.yaml

agents: check-login
	kubectl apply -n teleport -f k8s/teleport-agents.yaml

apply-ubuntu-client: check-login
	cd terraform/clients/ubuntu && terraform init && terraform apply -auto-approve

destroy-ubuntu-client: check-login
	cd terraform/clients/ubuntu && terraform destroy -auto-approve


apply-add-client: check-login
	cd terraform/clients/ad && terraform init && terraform apply -auto-approve

destroy-add-client: check-login
	cd terraform/clients/ad && terraform init && terraform destroy -auto-approve
