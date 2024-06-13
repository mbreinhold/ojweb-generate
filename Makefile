# For convenience, create a symbolic link to this file from the containing
# documentation repository, or else create a trivial Makefile:
#
#   $ echo 'include ojweb-generate/Makefile' >Makefile
# 

all preview clean:
	$(MAKE) -f ojweb-generate/ojweb.gmk $@

update:
	git -C ojweb-generate pull --ff-only

help:
	@echo '  make            Same as "make all"'
	@echo '  make all        Build all pages'
	@echo '  make preview    Start a tiny web server to preview the build'
	@echo '  make clean      Remove the build'
	@echo '  make update     Update ./ojweb-generate'

.PHONY: all preview clean update help
