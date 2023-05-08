# commands:
P := packer

#Fluence Edited Variables
AWS_DEFAULT_REGION = us-west-2
build_tag := $(or $(BUILD_TAG), $(shell date +%s))
encrypted := true
PACKER_BINARY = docker run -v /mnt/credentials:/root/.aws/credentials \
	-e AWS_SHARED_CREDENTIALS_FILE=/root/.aws/credentials \
	-v `pwd`/:/workspace -w /workspace \
	876270261134.dkr.ecr.us-west-2.amazonaws.com/devops/packer:1.6.1
PACKER_VARIABLES := aws_region ami_name binary_bucket_name binary_bucket_region kubernetes_version kubernetes_build_date kernel_version docker_version containerd_version runc_version cni_plugin_version source_ami_id source_ami_owners source_ami_filter_name arch instance_type security_group_id additional_yum_repos pull_cni_from_github sonobuoy_e2e_registry build_tag encrypted


#PACKER_BINARY ?= packer
#PACKER_VARIABLES := aws_region ami_name binary_bucket_name binary_bucket_region kubernetes_version kubernetes_build_date kernel_version docker_version containerd_version runc_version cni_plugin_version source_ami_id source_ami_owners source_ami_filter_name arch instance_type security_group_id additional_yum_repos pull_cni_from_github sonobuoy_e2e_registry
MAKEFILE_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PACKER_DEFAULT_VARIABLE_FILE ?= $(MAKEFILE_DIR)/eks-worker-al2-variables.json
PACKER_TEMPLATE_FILE ?= $(MAKEFILE_DIR)/eks-worker-al2.json
AVAILABLE_PACKER_VARIABLES := $(shell $(PACKER_BINARY) inspect -machine-readable $(PACKER_TEMPLATE_FILE) | grep 'template-variable' | awk -F ',' '{print $$4}')

K8S_VERSION_PARTS := $(subst ., ,$(kubernetes_version))
K8S_VERSION_MINOR := $(word 1,${K8S_VERSION_PARTS}).$(word 2,${K8S_VERSION_PARTS})

# expands to 'true' if PACKER_VARIABLE_FILE is non-empty
# and the file contains the string passed as the first argument
# otherwise, expands to 'false'
packer_variable_file_contains = $(if $(PACKER_VARIABLE_FILE),$(shell grep -Fq $1 $(PACKER_VARIABLE_FILE) && echo true || echo false),false)

# expands to 'true' if the version comparison is affirmative
# otherwise expands to 'false'
vercmp = $(shell $(MAKEFILE_DIR)/files/bin/vercmp "$1" "$2" "$3")

# expands to 'true' if the 'aws_region' contains 'us-iso' (an isolated region)
# otherwise, expands to 'false'
in_iso_region = $(if $(findstring us-iso,$(aws_region)),true,false)

# gp3 volumes are used by default for 1.27+
# TODO: remove when 1.26 reaches EOL
# TODO: remove when gp3 is supported in isolated regions
ifneq ($(call packer_variable_file_contains,volume_type), true)
	ifeq ($(call in_iso_region), true)
		volume_type ?= gp2
	else ifeq ($(call vercmp,$(kubernetes_version),lt,1.27.0), true)
		volume_type ?= gp2
	endif
endif

# Docker is not present on 1.25+ AMI's
# TODO: remove this when 1.24 reaches EOL
ifeq ($(call vercmp,$(kubernetes_version),gteq,1.25.0), true)
	# do not tag the AMI with the Docker version
	docker_version ?= none
	# do not include the Docker version in the AMI description
	ami_component_description ?= (k8s: {{ user `kubernetes_version` }}, containerd: {{ user `containerd_version` }})
endif

arch ?= x86_64
ifeq ($(arch), arm64)
	instance_type ?= m6g.large
	ami_name ?= amazon-eks-arm64-node-$(K8S_VERSION_MINOR)-v$(shell date +'%Y%m%d%H%M%S')
else
	instance_type ?= m4.large
	ami_name ?= amazon-eks-node-$(K8S_VERSION_MINOR)-v$(shell date +'%Y%m%d%H%M%S')
endif

ifeq ($(aws_region), cn-northwest-1)
	source_ami_owners ?= 141808717104
endif

ifeq ($(aws_region), us-gov-west-1)
	source_ami_owners ?= 045324592363
endif

T_RED := \e[0;31m
T_GREEN := \e[0;32m
T_YELLOW := \e[0;33m
T_RESET := \e[0m

.PHONY: all 1.18 1.19 1.20 1.21 1.22 1.26

all: 1.26-build

all-validate: 1.26-validate

.PHONY: latest
latest: 1.26 ## Build EKS Optimized AL2 AMI with the latest supported version of Kubernetes

# ensure that these flags are equivalent to the rules in the .editorconfig
SHFMT_FLAGS := --list \
--language-dialect auto \
--indent 2 \
--binary-next-line \
--case-indent \
--space-redirects

SHFMT_COMMAND := $(shell which shfmt)
ifeq (, $(SHFMT_COMMAND))
	SHFMT_COMMAND = docker run --rm -v $(MAKEFILE_DIR):$(MAKEFILE_DIR) mvdan/shfmt
endif

.PHONY: fmt
fmt: ## Format the source files
	$(SHFMT_COMMAND) $(SHFMT_FLAGS) --write $(MAKEFILE_DIR)

SHELLCHECK_COMMAND := $(shell which shellcheck)
ifeq (, $(SHELLCHECK_COMMAND))
	SHELLCHECK_COMMAND = docker run --rm -v $(MAKEFILE_DIR):$(MAKEFILE_DIR) koalaman/shellcheck:stable
endif
SHELL_FILES := $(shell find $(MAKEFILE_DIR) -type f -name '*.sh')

.PHONY: lint
lint: ## Check the source files for syntax and format issues
	$(SHFMT_COMMAND) $(SHFMT_FLAGS) --diff $(MAKEFILE_DIR)
	$(SHELLCHECK_COMMAND) --format gcc --severity error $(SHELL_FILES)

.PHONY: test
test: ## run the test-harness
	test/test-harness.sh

.PHONY: validate
validate: ## Validate packer config
	$(PACKER_BINARY) validate $(PACKER_VAR_FLAGS) $(PACKER_TEMPLATE_FILE)

.PHONY: k8s
k8s: validate ## Build default K8s version of EKS Optimized AL2 AMI
	@echo "$(T_GREEN)Building AMI for version $(T_YELLOW)$(kubernetes_version)$(T_GREEN) on $(T_YELLOW)$(arch)$(T_RESET)"
	$(PACKER_BINARY) build -timestamp-ui -color=false $(PACKER_VAR_FLAGS) $(PACKER_TEMPLATE_FILE)

# Build dates and versions taken from https://docs.aws.amazon.com/eks/latest/userguide/install-kubectl.html

.PHONY: 1.19-validate
1.19-validate:
	$(MAKE) ci-validate kubernetes_version=1.19.15 kubernetes_build_date=2021-11-10 pull_cni_from_github=true

.PHONY: 1.19-build
1.19-build:
	$(MAKE) ci-build kubernetes_version=1.19.15 kubernetes_build_date=2021-11-10 pull_cni_from_github=true

.PHONY: 1.20-validate
1.20-validate:
	$(MAKE) ci-validate kubernetes_version=1.20.11 kubernetes_build_date=2021-11-10 pull_cni_from_github=true

.PHONY: 1.20-build
1.20-build:
	$(MAKE) ci-build kubernetes_version=1.20.11 kubernetes_build_date=2021-11-10 pull_cni_from_github=true

.PHONY: 1.21-validate
1.21-validate:
	$(MAKE) ci-validate kubernetes_version=1.21.14 kubernetes_build_date=2022-10-31 pull_cni_from_github=true

.PHONY: 1.21-build
1.21-build:
	$(MAKE) ci-build kubernetes_version=1.21.14 kubernetes_build_date=2022-10-31 pull_cni_from_github=true

.PHONY: 1.22-validate
1.22-validate:
	$(MAKE) ci-validate  kubernetes_version=1.22.17 kubernetes_build_date=2023-01-30 pull_cni_from_github=true

.PHONY: 1.22-build
1.22-build:
	$(MAKE) ci-build  kubernetes_version=1.22.17 kubernetes_build_date=2023-01-30 pull_cni_from_github=true

.PHONY: 1.26-validate
1.26-validate:
	$(MAKE) ci-validate  kubernetes_version=1.26.2 kubernetes_build_date=2023-03-17 pull_cni_from_github=true

.PHONY: 1.26-build
1.26-build:
	$(MAKE) ci-build  kubernetes_version=1.26.2 kubernetes_build_date=2023-03-17 pull_cni_from_github=true

# Circle CI pipeline
.PHONY: ci-validate
ci-validate:
	$(P) validate $(foreach packerVar,$(PACKER_VARIABLES), $(if $($(packerVar)),--var $(packerVar)='$($(packerVar))',)) eks-worker-al2.json

.PHONY: ci-build
ci-build:
	@echo "$(T_GREEN)Building AMI for version $(T_YELLOW)$(kubernetes_version)$(T_GREEN) on $(T_YELLOW)$(arch)$(T_RESET)"
	$(P) build $(foreach packerVar,$(PACKER_VARIABLES), $(if $($(packerVar)),--var $(packerVar)='$($(packerVar))',)) eks-worker-al2.json
