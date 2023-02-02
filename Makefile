.PHONY: reconfigure reconfigure-in-container step-0 step-0-in-container ci-bot ci-bot-in-container

ENV := dev

ifndef OS_ENV
ifneq ($(shell which docker),)
ENGINE := docker
else ifneq ($(shell which podman),)
ENGINE := podman
else
$(error Container engine can't be found)
endif
endif

ifeq ($(ENV), dev)
	ifndef AWS_REGION
	    AWS_REGION := $(shell aws configure get region)
	endif
	AWS_PROFILE := default
else ifeq ($(ENV), ci)
	AWS_REGION := ${AWS_REGION}
else ifeq ($(ENV), stage)
	AWS_REGION := ${AWS_REGION}
	AWS_PROFILE := stage
endif

HELPER_IMAGE := ghcr.io/platform-engineering-org/helper:latest
in_container = ${ENGINE} run --rm --name bootstrap -v $(PWD):/workspace:rw -v ~/.aws:/root/.aws:ro -w /workspace --security-opt label=disable --env USER=${USER} --env OS_ENV=container ${HELPER_IMAGE} make $1
TERRAGRUNT_CMD = cd live/${ENV}/ci-bot && terragrunt

step-0-in-container:
	ansible-galaxy install -r ./step_0/requirements.yml
	ANSIBLE_CONFIG="./step_0/ansible.cfg" ansible-playbook ./step_0/main.yml

step-0:
	$(call in_container,step-0-in-container)

ci-bot-in-container:
	${TERRAGRUNT_CMD} apply -auto-approve -var "user=${USER}" -var "aws_region=${AWS_REGION}" -var "aws_profile=${AWS_PROFILE}"

ci-bot:
	$(call in_container,ci-bot-in-container)


reconfigure-in-container:
	${TERRAGRUNT_CMD} init --reconfigure

reconfigure:
	$(call in_container,reconfigure-in-container)
