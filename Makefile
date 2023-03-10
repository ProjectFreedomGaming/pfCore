# SPDX-FileCopyrightText: 2023-present pfSDK contributors
#
# SPDX-License-Identifier: GPL-3.0-or-later

.PHONY: default
default: all ;

ifeq ($(PF_POCKET_CORE_DEV_DIR),)
 $(error Error: PF_POCKET_CORE_DEV_DIR needs to be defined and pointing to a clone of https://github.com/ProjectFreedomGaming/pocket-core-dev.git.)
endif

# -- Constants
BUILD_DIR = _build
DEPENDENCY_FILE = $(BUILD_DIR)/deps.d

# -- Verilog files
SRC_VERILOG_DIR = src
SRC_VERILOG_FILES = $(shell find $(SRC_VERILOG_DIR) -name "*.v")
SRC_SYSTEM_VERILOG_FILES = $(shell find $(SRC_VERILOG_DIR) -name "*.sv")
DEST_VERILOG_DIR = $(PF_POCKET_CORE_DEV_DIR)/src/fpga
VERILOG_FILES = $(SRC_VERILOG_FILES:$(SRC_VERILOG_DIR)/%.v=$(DEST_VERILOG_DIR)/%.v)
SYSTEM_VERILOG_FILES =  $(SRC_SYSTEM_VERILOG_FILES:$(SRC_VERILOG_DIR)/%.sv=$(DEST_VERILOG_DIR)/%.sv)
CONFIG_FILE = src/config.toml
CORE_FILE = _build/$(shell pfBuildCore --corefilename $(CONFIG_FILE))

# -- Rules
$(CORE_FILE):
	@bin/pfBuildCore $(CONFIG_FILE) $(BUILD_DIR)

# -- The .SECONDEXPANSION: is needed to enable the $$ rules for GNU Make.
# -- It is needed to allow target based substitution rules in the prerequisites for $(C_OBJECTS) and $(ASM_OBJECTS).
.SECONDEXPANSION:
	
# -- The prerequisite $$(patsubst $(BUILD_DIR)/%.o,$(SRC_DIR)/%.c,$$@) is saying,
# -- that the current target depends on a specific source file with the same folder structure and name.
$(VERILOG_FILES): $$(patsubst $(DEST_VERILOG_DIR)/%.v,$(SRC_VERILOG_DIR)/%.v,$$@)
	$(info Updating $<...)
	@mkdir -p $(@D)
	@cp $< $@

$(SYSTEM_VERILOG_FILES): $$(patsubst $(DEST_VERILOG_DIR)/%.sv,$(SRC_VERILOG_DIR)/%.sv,$$@)
	$(info Updating $<...)
	@mkdir -p $(@D)
	@cp $< $@

# -- Include any dependency files generated by the core building script.
-include $(BUILD_DIR)/deps.d
 
all: $(CORE_FILE)
	@:

update: $(VERILOG_FILES) $(SYSTEM_VERILOG_FILES)
	@:
		
install: $(CORE_FILE)
	bin/pfInstallCore $(CORE_FILE) /Volumes/POCKET/

# -- Cleaning just requires deleting the build folder.
clean:
	$(info Cleaning project.)
	@rm -Rf $(BUILD_DIR)
