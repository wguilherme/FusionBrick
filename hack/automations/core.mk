SHELL := /bin/bash
AUTOMATIONS_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

include $(AUTOMATIONS_DIR)openscad.mk

.PHONY: openscad-preview openscad-build

openscad-%:
	@$(MAKE) -f $(AUTOMATIONS_DIR)openscad.mk $(patsubst openscad-%,%,$@)
