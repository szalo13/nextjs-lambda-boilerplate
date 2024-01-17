plan:
	terraform workspace select $(WORKSPACE)
	terraform plan -var-file=./env/$(WORKSPACE).tfvars

apply:
	terraform workspace select $(WORKSPACE)
	terraform apply -var-file=./env/$(WORKSPACE).tfvars

plan-prod:
	WORKSPACE=prod make plan

apply-prod:
	WORKSPACE=prod make apply

plan-dev:
	WORKSPACE=dev make plan

apply-dev:
	WORKSPACE=dev make apply