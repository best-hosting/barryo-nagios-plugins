
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
else
    builddir	    ?= build
    builddir	    := $(builddir)/$(notdir $(CURDIR))
endif
export builddir
srcdir		    := .

rsnapshot_configs   := $(shell find /etc -name 'rsnapshot*.conf' 2>/dev/null)

project_top	    := $(plugindir)/check_rsnapshot
project_bin	    := $(sbindir)/checkrsnapshot
project_nrpe	    := $(confdir_nrpe)/check_rsnapshot.cfg

programs	    := top bin
data		    := nrpe send-cache

test :
	@./bin/checkrsnapshot.sh $$(find /etc -name 'rsnapshot*.conf' 2>/dev/null)

include ./common-build/Makefile.common

$(builddir)/nrpe/check_rsnapshot.cfg : $(rsnapshot_configs)
	$(mkdir) $$(dirname $@)
	./bin/checkrsnapshot.sh $^ > "$@"

