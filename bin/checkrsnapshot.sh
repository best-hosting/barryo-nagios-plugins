#!/bin/sh

# This file is part of "barryo / nagios-plugins" - a library of tools and
# utilities for Nagios developed by Barry O'Donovan
# (http://www.barryodonovan.com/) and his company, Open Solutions
# (http://www.opensolutions.ie/).
#
# Copyright (c) 2015, Best Hosting Company, Moscow, Russia
# All rights reserved.
#
# Contact: sgf.dma@gmail.com
#
# LICENSE
#
# Redistribution and use in source and binary forms, with or without modification,
# are permitted provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
#  * Redistributions in binary form must reproduce the above copyright notice, this
#    list of conditions and the following disclaimer in the documentation and/or
#    other materials provided with the distribution.
#
#  * Neither the name of Open Solutions nor the names of its contributors may be
#    used to endorse or promote products derived from this software without
#    specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
# INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
# LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
# OF THE POSSIBILITY OF SUCH DAMAGE.
#
# @package    barryo / nagios-plugins
# @copyright  Copyright (c) 2015, Best Hosting Company, Moscow, Russia
# @license    http://www.opensolutions.ie/licenses/new-bsd New BSD License
# @link       http://www.opensolutions.ie/ Open Source Solutions Limited

# Run check_rsnapshot plugin so that, it's output will be written to cache
# file (understand by send-cache plugin) with name guessed from rsnapshot
# config file name (all arguments are passed-through to check_rsnapshot).  In
# order to write check_rsnapshot output to non-default cache (i.e. to have
# per-rsnapshot-config caches), rsnapshot config file name must have format
# 'rsnapshotXinstance.conf', where X is non-word separator (according to sed's
# \w and \b escapes), "rsnapshot" and ".conf" parts are matched literally and
# "instance" is an instance name. Cache file then will be named
# 'check_rsnapshot_instance.cache' and placed in default send-cache's
# directory. If instance can't be determined, write-plugin-cache will write to
# default plugin cache.
#
# If this script invoked from make, it assumes, that all arguments are pathes
# to rsnapshot config files and output corresponding nrpe commands, one per
# line. nrpe commands will have format 'check_rsnapshot_instance' for each
# recognized instance.

set -euf

nl='
'

# Try to find config file path among cmd arguments (search for '-c path' as
# check_rsnapshot expects).
lookup_config()
{
    local config=''

    while [ $# -gt 0 ]; do
        case "$1" in
          '-c' )
            if [ -n "${2:-}" ]; then
                config="$2"
            fi
            break
          ;;
          '--' )
            break
          ;;
        esac
        shift
    done
    echo "$config"
}

# Derive instance name from rsnapshot's config file path If instance name
# can't be derived, output empty string.
get_instance()
{
    local conf_name_erx='^(.*/)?rsnapshot\b.([^/]+)\.conf$'
    local res=''

    res="$(echo "$1" \
            | sed -r -ne "2q;
                \%${conf_name_erx}% {
                    s%${conf_name_erx}%\2%;
                    s%[.-]%_%g;
                    h;
                }
                \${ x; p; };"
        )"
    echo "$res"
}

# Derive cache file name from rsnapshot's config file path (calls
# get_instance() internally) and output send-cache (or write-plugin-cache)
# options for using generated cache file. If instance is empty, no options
# will be output, and then send-cache and write-plugin-cache will try to use
# default cache. That means, that i should always pass plugin name to them (so
# they can derive default cache name) and that i should check default plugin
# cache too (in case some instance won't work).
#
# Output options separated by first IFS char.
get_cache_opt()
{
    local config="$1"
    local instance=''
    local cache=''

    instance="$(get_instance "$config")"
    cache="${instance:+check_rsnapshot_${instance}.cache}"
    # Separate '--cache' and cache file name by first char of IFS.
    set -- '--cache' "$cache"
    if [ -n "$2" ]; then
	echo "$*"
    fi
}

if [ -n "${MAKELEVEL:-}" -a "${MAKEFLAGS+x}" = 'x' ]; then
    # Assume, that invoked from make.
    # Args:
    # 1.. - rsnapshot config file pathes.
    # Generate nrpe command for each rsnapshot config (number of commands will
    # be equal to number of config files). And if for some configs i can't
    # guess instance, several default commands (identical) will be output.
    for i; do
        instance="$(get_instance "$1")"
        cache_opt="$(get_cache_opt "$1")"
        echo -n "command[check_rsnapshot${instance:+_$instance}]="
        echo -n "/usr/local/lib/nagios/plugins/send_cache $cache_opt /usr/local/lib/nagios/plugins/check_rsnapshot"
        echo
        shift;
    done
else
    # Normal invocation. Exec write-plugin-cache with guessed from arguments
    # cache file for running check_rsnapshot plugin and pass-through all
    # arguments.
    IFS="$nl"
    cache_opt="$(get_cache_opt "$(lookup_config "$@")")"
    exec /usr/local/sbin/write-plugin-cache $cache_opt \
        /usr/local/lib/nagios/plugins/check_rsnapshot "$@"
fi

