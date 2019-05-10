#!/bin/bash
#
# nvidiagpubeat          nvidiagpubeat shipper
#
# chkconfig: 2345 98 02
# description: Starts and stops a single nvidiagpubeat instance on this system
#

### BEGIN INIT INFO
# Provides:          nvidiagpubeat
# Required-Start:    $local_fs $network $syslog
# Required-Stop:     $local_fs $network $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: nvidiagpubeat sends GPU metrics to Elasticsearch.
# Description:       nvidiagpubeat is a shipper part of the Elastic Beats
#                    family. Please see: https://www.elastic.co/products/beats
### END INIT INFO



PATH=/usr/bin:/sbin:/bin:/usr/sbin
export PATH

[ -f /etc/sysconfig/nvidiagpubeat ] && . /etc/sysconfig/nvidiagpubeat
pidfile=${PIDFILE-/var/run/nvidiagpubeat.pid}
agent=${BEATS_AGENT-/usr/share/nvidiagpubeat/bin/nvidiagpubeat}
args="-c /etc/nvidiagpubeat/nvidiagpubeat.yml -E seccomp.enabled=false -path.home /usr/share/nvidiagpubeat -path.config /etc/nvidiagpubeat -path.data /var/lib/nvidiagpubeat -path.logs /var/log/nvidiagpubeat"
wrapper="/usr/share/nvidiagpubeat/bin/nvidiagpubeat-god"
wrapperopts="-r / -n -p $pidfile"
RETVAL=0

# Source function library.
. /etc/rc.d/init.d/functions

# Determine if we can use the -p option to daemon, killproc, and status.
# RHEL < 5 can't.
if status | grep -q -- '-p' 2>/dev/null; then
    daemonopts="--pidfile $pidfile"
    pidopts="-p $pidfile"
fi

start() {
    echo -n $"Starting nvidiagpubeat: "
    daemon $daemonopts $wrapper $wrapperopts -- $agent $args
    RETVAL=$?
    echo
    return $RETVAL
}

stop() {
    echo -n $"Stopping nvidiagpubeat: "

    killproc $pidopts $wrapper
    RETVAL=$?
    echo
    [ $RETVAL = 0 ] && rm -f ${pidfile}
}

restart() {
    stop
    start
}

rh_status() {
    status $pidopts $wrapper
    RETVAL=$?
    return $RETVAL
}

rh_status_q() {
    rh_status >/dev/null 2>&1
}

case "$1" in
    start)
        start
    ;;
    stop)
        stop
    ;;
    restart)
        restart
    ;;
    condrestart|try-restart)
        rh_status_q || exit 0
        restart
    ;;
    status)
        rh_status
    ;;
    *)
        echo $"Usage: $0 {start|stop|status|restart|condrestart}"
        exit 1
esac

exit $RETVAL

