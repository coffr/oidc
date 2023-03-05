.PHONY: init reconfigure upgrade plan up down init-in-container \
		reconfigure-in-container upgrade-in-container plan-in-container \
		up-in-container down-in-container \
		audit audit-in-container

ENV := dev

ifndef OS_ENV
    ifneq ($(shell command -v docker),)
        ENGINE := docker
    else ifneq ($(shell command -v podman),)
        ENGINE := podman
    else
        $(error Container engine can't be found)
    endif
endif

ifeq ($(ENV), dev)
	ifndef AWS_REGION
	    AWS_REGION := $(shell aws configure get region)
	endif
else ifeq ($(ENV), ci)
	AWS_REGION := ${AWS_REGION}
else ifeq ($(ENV), prod)
	AWS_REGION := ${AWS_REGION}
endif

HELPER_IMAGE := ghcr.io/platform-engineering-org/helper:latest
in_container = ${ENGINE} run --rm --name bootstrap -v $(PWD):/workspace:rw -v ~/.aws:/root/.aws:ro -w /workspace --security-opt label=disable --env USER=${USER} --env OS_ENV=container ${HELPER_IMAGE} echo ${ENV} && make $1
TERRAGRUNT_CMD = cd live/${ENV} && terragrunt run-all --terragrunt-non-interactive


init-in-container:
	${TERRAGRUNT_CMD} init

reconfigure-in-container:
	${TERRAGRUNT_CMD} init --reconfigure

upgrade-in-container:
	${TERRAGRUNT_CMD} init -upgrade

plan-in-container:
	${TERRAGRUNT_CMD} plan -var "user=${USER}" -var "aws_region=${AWS_REGION}"

up-in-container:
	${TERRAGRUNT_CMD} apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

down-in-container:
	${TERRAGRUNT_CMD} destroy -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

audit-in-container:
	cd live/${ENV}/audit && terragrunt run-all --terragrunt-non-interactive apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}"

init:
	$(call in_container,init-in-container)

reconfigure:
	$(call in_container,reconfigure-in-container)

upgrade:
	$(call in_container,upgrade-in-container)

plan:
	$(call in_container,plan-in-container)

up:
	$(call in_container,up-in-container)

down:
	$(call in_container,down-in-container)

audit:
	$(call in_container,audit-in-container)
