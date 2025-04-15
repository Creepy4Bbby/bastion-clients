apply:
	cd terraform && terraform init && terraform apply -auto-approve

destroy:
	cd terraform && terraform destroy -auto-approve

ansible:
	cd ansible && ansible-playbook -i inventory.ini playbook.yml
