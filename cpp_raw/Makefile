include Makefile.builtem

EXECUTABLES = $(call exe,benchmark)
all: $(EXECUTABLES)

# executables
C_FLAGS += $(call include_dir,.)
$(call exe,benchmark): $(call obj, parsito/tree/tree parsito/tree/tree_format parsito/tree/tree_format_conllu)
$(EXECUTABLES): $(call exe,%): $$(call obj,%)
	$(call link_exe,$@,$^,$(call win_subsystem,console))

# cleaning
.PHONY: clean
clean:
	$(call rm,.build $(call all_exe,$(EXECUTABLES)))
