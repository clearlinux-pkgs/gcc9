PKG_NAME := gcc9

include ../common/Makefile.common

GCCGIT = ~/git/gcc
GCCVER = 9.5.0

GCCTAG = releases/gcc-$(GCCVER)
GCCBRANCH = origin/releases/gcc-$(shell echo $(GCCVER) | sed 's/\..*//')

update:
	git -C $(GCCGIT) remote update -p
	git -C $(GCCGIT) rev-parse --verify --quiet refs/tags/$(GCCTAG) > /dev/null
	git -C $(GCCGIT) rev-parse --verify --quiet $(GCCBRANCH) > /dev/null
	git -C $(GCCGIT) diff $(GCCTAG)..$(GCCBRANCH) -- \* ':!*/DATESTAMP' > new.patch~
	git show HEAD:gcc-stable-branch.patch | sed -n '/^diff --git/,$$p' > current.patch~
	! diff current.patch~ new.patch~ > /dev/null
	git -C $(GCCGIT) shortlog $(GCCTAG)..$(GCCBRANCH) > gcc-stable-branch.patch
	cat new.patch~ >> gcc-stable-branch.patch
	rm -f *.patch~
	git -C $(GCCGIT) show $(GCCBRANCH):gcc/DATESTAMP > DATESTAMP
	git -C $(GCCGIT) describe --abbrev=10 --match 'releases/*' $(GCCBRANCH) > REVISION
	$(MAKE) bumpnogit
	git commit -m "stable update to `cat REVISION`" -a
	test -n "$(NO_KOJI)" || $(MAKE) koji-nowait
