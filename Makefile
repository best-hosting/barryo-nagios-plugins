
# Defaults for installation directories. No trailing slash.
prefix		    ?= /usr/local
sbindir		    ?= $(prefix)/sbin
plugindir	    ?= $(prefix)/lib/nagios/plugins
confdir 	    ?= /etc
confdir_nrpe 	    ?= $(confdir)/nagios/nrpe.d

# Use build directory in current directory, if invoked manually, and in
# central build directory otherwise.
ifeq ($(MAKELEVEL), 0)
    builddir	    := build
else
    builddir	    ?= build
    builddir	    := $(builddir)/$(notdir $(CURDIR))
endif
srcdir		    := .

project_top	    := $(plugindir)/check_rsnapshot
project_bin	    := $(sbindir)/checkrsnapshot
project_nrpe	    := $(confdir_nrpe)/check_rsnapshot.cfg

programs	    := top bin
data		    := nrpe

include ./common-build/Makefile.common

