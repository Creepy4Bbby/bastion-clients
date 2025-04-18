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
	

	@echo "Teleport installed. Waiting for pods to be ready..."
	kubectl wait --for=condition=available --timeout=600s -n teleport deployment/teleport-teleport
	@echo "Teleport is ready."
	@echo "Teleport is ready. You can access it at https://teleport.efrei.online:3080"
	kubectl exec -it -n teleport pod/teleport_id -- tctl users add admin --roles=editor,auditor,access
	# #  Mettre id du pod auth

teleportupdate:	check-login

	helm upgrade --install teleport teleport/teleport-cluster \
  --namespace teleport --create-namespace \
  -f helm/values.yaml

agents: check-login
	kubectl apply -n teleport -f k8s/teleport-agents.yaml

apply-clients: check-login
	cd terraform/clients && terraform init && terraform apply -auto-approve

destroy-clients: check-login
	cd terraform/clients && terraform destroy -auto-approve
