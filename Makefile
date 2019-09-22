
SHELL	:= /bin/sh
PKGDIR	:= $(shell pwd)
PACKAGE	:= $(shell basename $(PKGDIR) )
VERSION	:= $(shell date +%Y%m%d)

.SUFFIXES:
.SUFFIXES: .html .txt

prefix		= /usr/local
exec_prefix	= $(prefix)
bindir		= $(exec_prefix)/bin
sbindir		= $(exec_prefix)/sbin
libexecdir	= $(exec_prefix)/libexec

datarootdir	= $(prefix)/share
datadir		= $(datarootdir)

sysconfdir	= $(prefix)/etc

sharedstatedir	= $(prefix)/com

localstatedir	= $(prefix)/var
runstatedir	= $(localstatedir)/run

includedir	= $(prefix)/include

oldincludedir	= /usr/include

docdir		= $(datarootdir)/doc/$(PACKAGE)

infodir		= $(datarootdir)/info

htmldir		= $(docdir)
dvidir		= $(docdir)
pdfdir		= $(docdir)
psdir			= $(docdir)

libdir		= $(exec_prefix)/lib

lispdir		= $(datarootdir)/emacs/site-lisp

localedir	= $(datarootdir)/locale

mandir		= $(datarootdir)/man
man1dir		= $(mandir)/man1
man2dir		= $(mandir)/man2

manext		= .1
man1ext		= .1.gz
man2ext		= .2.gz

srcdir		= $(shell pwd)

LOCAL_LIBDIR	:= $(srcdir)/lib

GEMFILE	:= today-$(VERSION).gem

SOURCES	:= lib/today/*rb bin/today.rb

CRAM			:= cram
CRAMFLAGS	:= -E -v
CRAMTESTS	:= cram/*.t

DMD				:= dmd
DMDFLAGS	:= -g -release
DMDFLAGSUNIT	:= -g -unittest
DMDFLAGSPROFILE	:= $(DMDFLAGS) -profile

DMD_TARGET	:= $(PACKAGE)
DMD_TARGET_UNIT	:= $(PACKAGE)_unit
DMD_TARGET_PROFILE	:= $(PACKAGE)_profile

RUBYFILES	:= $(SOURCES)
RUBYLINT	:= ruby-lint
RUBYLINTFLAGS	:= -a warning

RUBOCOP	:= rubocop
RUBOCOPFLAGS	:=

DSCANNER	:= dscanner
DSCANNERFLAGS	:= --config dscanner.ini -S

INSTALL		= install
INSTALL_PROGRAM = $(INSTALL) -m 0755
INSTALL_DATA 	= $(INSTALL) -m 0644
INSTALL_DIR 	= $(INSTALL) -d -m 0755

%:	%.in
	m4 -D M4_VERSION=$(VERSION) $< > $@

all:	$(DMD_TARGET)

$(DMD_TARGET):	src/*.d
	$(DMD) $(DMDFLAGS) src/*.d -of$(DMD_TARGET)

$(DMD_TARGET_UNIT):	src/*.d
	$(DMD) $(DMDFLAGSUNIT) src/*.d -of$(DMD_TARGET_UNIT)

$(DMD_TARGET_PROFILE):	src/*.d
	$(DMD) $(DMDFLAGSPROFILE) src/*.d -of$(DMD_TARGET_PROFILE)

install:	dist
	$(INSTALL_PROGRAM) $(DMD_TARGET) $(DESTDIR)$(bindir)/today_d

uninstall:

clean:
	rm -f $(DMD_TARGET) $(DMD_TARGET_UNIT) *.o

distclean:	clean
	@echo "No distclean"

check:	check_dmd

check_run_dmd:	$(DMD_TARGET)
	time ( ./$(DMD_TARGET) > /dev/null )
	time ( ./$(DMD_TARGET) ls > /dev/null )
	time ( ./$(DMD_TARGET) ls -a > /dev/null )

check_dmd:	$(DMD_TARGET_UNIT)
	TODAY="$(srcdir)/$(DMD_TARGET_UNIT)" $(CRAM) $(CRAMFLAGS) $(CRAMTESTS)

check_run:	check_run_dmd

unit:	$(DMD_TARGET_UNIT)
	./$(DMD_TARGET_UNIT)

lint_dscanner:
	$(DSCANNER) $(DSCANNERFLAGS) src/*.d

lint_rubylint:
	set -e ; $(RUBYLINT) $(RUBYLINTFLAGS) $(RUBYFILES)

lint_rubocop:
	set -e ; $(RUBOCOP) $(RUBOCOPFLAGS) $(RUBYFILES)

lint:	lint_dscanner

doc:	$(DOCS)

TAGS:
	ctags -R .

dist:

.PHONY:	all
.PHONY:	clean
.PHONY:	lint lint_rubylint lint_rubocop

