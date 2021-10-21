# For convenience, create a symbolic link to this file
# from the containing documentation repository

all preview clean:
	$(MAKE) -f ojweb-generate/ojweb.gmk $@

update:
	git -C ojweb-generate pull --ff-only

.PHONY: all preview clean update
