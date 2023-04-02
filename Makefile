.PHONY: init reconfigure upgrade plan up down audit

ENV := dev

TERRAGRUNT_CMD = cd live/${ENV} && terragrunt run-all --terragrunt-non-interactive


init:
	${TERRAGRUNT_CMD} init

reconfigure:
	${TERRAGRUNT_CMD} init --reconfigure

upgrade:
	${TERRAGRUNT_CMD} init -upgrade

plan:
	${TERRAGRUNT_CMD} plan

up:
	${TERRAGRUNT_CMD} apply -auto-approve

down:
	${TERRAGRUNT_CMD} destroy -auto-approve

audit:
	cd live/${ENV}/audit && terragrunt run-all --terragrunt-non-interactive apply -auto-approve
