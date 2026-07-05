SHELL := /bin/bash
ROOT_DIR := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))

include $(ROOT_DIR)hack/automations/core.mk
