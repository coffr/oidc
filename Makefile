.PHONY: step-0 step-0-in-container

ifndef OS_ENV
ifneq ($(shell which docker),)
ENGINE := docker
else ifneq ($(shell which podman),)
ENGINE := podman
else
$(error Container engine can't be found)
endif
endif

HELPER_IMAGE := ghcr.io/platform-engineering-org/helper:latest
in_container = ${ENGINE} run --rm --name bootstrap -v $(PWD):/workspace:rw -v ~/.aws:/root/.aws:ro -w /workspace --security-opt label=disable --env USER=${USER} --env OS_ENV=container ${HELPER_IMAGE} make $1

step-0-in-container:
	ansible-galaxy install -r ./step_0/requirements.yml
	ANSIBLE_CONFIG="./step_0/ansible.cfg" ansible-playbook ./step_0/main.yml

step-0:
	$(call in_container,step-0-in-container)
