DC              := ldc
D_FLAGS         := -unittest
INSTALL_PREFIX  := /usr/local
XFBUILD         := $(shell which xfbuild)
EXAMPLE_FILES   := rosenbrock.d
EXAMPLE_NAME    := rosenbrock
OPTIMIZER_NAME  := optimizer
OPTIMIZER_FILES := main.d de.d grid.d help.d algorithm.d limits.d normal_runner.d parallel_runner.d runner.d

.PHONY : all
all : $(OPTIMIZER_NAME)

.PHONY : example
example : $(EXAMPLE_NAME)

.PHONY : install
install : $(INSTALL_PREFIX)/bin/$(OPTIMIZER_NAME)

$(INSTALL_PREFIX)/bin/$(OPTIMIZER_NAME) : $(OPTIMIZER_NAME)
	install $(OPTIMIZER_NAME) $(INSTALL_PREFIX)/bin/

$(EXAMPLE_NAME) : $(EXAMPLE_FILES)
ifeq ($(XFBUILD),)
	$(DC) -of$(EXAMPLE_NAME) -od=".objs_$(EXAMPLE_NAME)" $(D_FLAGS) $(EXAMPLE_FILES)
else
	$(XFBUILD) +D=".deps_$(EXAMPLE_NAME)" +O=".objs_$(EXAMPLE_NAME)" +threads=6 +q +o$(EXAMPLE_NAME) +c$(DC) +x$(DC) +xtango $(EXAMPLE_FILES) $(D_FLAGS)
	rm -f *.rsp
endif

$(OPTIMIZER_NAME) : $(OPTIMIZER_FILES)
ifeq ($(XFBUILD),)
	$(DC) -of$(OPTIMIZER_NAME) -od=".objs_$(OPTIMIZER_NAME)" $(D_FLAGS) $(OPTIMIZER_FILES)
else
	$(XFBUILD) +D=".deps_$(OPTIMIZER_NAME)" +O=".objs_$(OPTIMIZER_NAME)" +threads=6 +q +o$(OPTIMIZER_NAME) +c$(DC) +x$(DC) +xtango $(OPTIMIZER_FILES) $(D_FLAGS)
	rm -f *.rsp
endif

.PHONY : clean
clean :
	rm -f rosenbrock optimizer .deps*
	rm -rf .objs*
	rm -f *.rsp
