#! /bin/sh
# {{ fullname }}
# Maintainer: @tim
# Authors: @tim

# PROVIDE: {{ fullname }}
# REQUIRE: LOGIN
# KEYWORD: shutdown

. /etc/rc.subr

name="{{ fullname }}"
rcvar="{{ fullname }}_enable"

load_rc_config {{ fullname }}

: ${{ '{' }}{{ fullname }}_enable:="NO"}
: ${{ '{' }}{{ fullname }}_user:="{{ user }}"}

required_dirs={{ directory }}

pidfile={{ directory }}/daemon.pid
logfile=/var/log/{{ fullname }}.log
procname={{ executable }}
command=/usr/sbin/daemon
command_args="-p ${pidfile} -f ${procname} -o ${logfile} -config={{ config }}"

start_precmd="oauth2_proxy_precmd"

oauth2_proxy_precmd()
{
    install -o {{ user }} /dev/null ${pidfile}

    export PATH="${PATH}:/usr/local/bin:/usr/local/sbin"
    cd {{ directory }}
}

run_rc_command "$1"
