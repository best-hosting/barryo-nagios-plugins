
# Defaults for installation directories. No trailing slash.
prefix		    ?= /usr/local
sbindir		    ?= $(prefix)/sbin
plugindir	    ?= $(prefix)/lib/nagios/plugins
confdir 	    ?= /etc
confdir_nrpe 	    ?= $(confdir)/nagios/nrpe.d

# $(builddir) is passed to send-cache's Makefile and, thus, must contain full
# # path.
ifeq ($(MAKELEVEL), 0)
    builddir	    := $(CURDIR)/build
    # I build send-cache only, if this is top-level project.  Otherwise,
    # parent project should include send-cache explicitly.
    data	    := send-cache
else
    builddir	    ?= build
    builddir	    := $(builddir)/$(notdir $(CURDIR))
endif
export builddir
srcdir		    := .

project_top	    := $(plugindir)/check_rsnapshot
project_bin	    := $(sbindir)/checkrsnapshot
project_nrpe	    := $(confdir_nrpe)/check_rsnapshot.cfg

programs	    := top bin
data		    := $(data) nrpe

include ./common-build/Makefile.common

