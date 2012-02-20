DC              := ldc2
DCOMPILER       := ldc
D_FLAGS         := -g -unittest -w -wi -property -L-ltango-$(DCOMPILER)
INSTALL_PREFIX  := /usr/local
XFBUILD         := $(shell which xfbuild)
EXAMPLE_FILES   := rosenbrock.d
EXAMPLE_NAME    := rosenbrock
OPTIMIZER_NAME  := optimizer
OPTIMIZER_FILES := main.d de.d grid.d help.d algorithm.d limits.d normal_runner.d parallel_runner.d runner.d

# Compiles a D program
# $1 - program name
# $2 - program files
ifeq ($(XFBUILD),)
    define d_build
        $(DC) -of$1 -od=".objs_$1" $(D_FLAGS) $2
    endef
else
    define d_build
        $(XFBUILD) +D=".deps_$1" +O=".objs_$1" +threads=6 +q +o$1 +c$(DC) +x$(DCOMPILER) +xcore +xtango $2 $(D_FLAGS)
        rm -f *.rsp
    endef
endif

.PHONY : all
all : $(OPTIMIZER_NAME)

.PHONY : example
example : $(EXAMPLE_NAME)

.PHONY : install
install : $(INSTALL_PREFIX)/bin/$(OPTIMIZER_NAME)

$(INSTALL_PREFIX)/bin/$(OPTIMIZER_NAME) : $(OPTIMIZER_NAME)
	install $(OPTIMIZER_NAME) $(INSTALL_PREFIX)/bin/

$(EXAMPLE_NAME) : $(EXAMPLE_FILES)
	$(call d_build,$(EXAMPLE_NAME),$(EXAMPLE_FILES))

$(OPTIMIZER_NAME) : $(OPTIMIZER_FILES)
	$(call d_build,$(OPTIMIZER_NAME),$(OPTIMIZER_FILES))

.PHONY : clean
clean :
	rm -f rosenbrock optimizer .deps*
	rm -rf .objs*
	rm -f *.rsp
