#!/bin/bash

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
marker=$(printf "%80s" | sed "s/ /./g")
cmd=$HOME/bin/arwrapper.bash
subcmd=${1:-run}
rc=0

verbose="1"
log="1"
logfile=/var/log/ansible-cron-audit.log

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
function log-ok {
    (($verbose)) && printf "[OK]  $message\n"
    (($log)) && printf "`date "+%F %T"` [OK]  $message\n" >> $logfile
}
function log-dbg {
    if [[ $debug -eq 1 ]]; then
	printf "[DBG] $message\n"
	(($log)) && printf "`date "+%F %T"` [DBG] lectl: $message\n" >> $logfile
    fi
}
function log-err {
    printf "[ERR] $message\n"
    (($log)) && printf "`date "+%F %T"` [ERR] lectl: $message\n" >> $logfile
    }

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
typeset -A projects
projects=(
    [host1]="test-01.yml test-02.yml test-03.yml"
    [host2]="test-01.yml test-02.yml test-03.yml"
    [host3]="test-01.yml test-02.yml test-03.yml"
)

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
for project in "${!projects[@]}"; do
    for playbook in ${projects[$project]}; do
	out=$("$cmd" "$subcmd" "$project" "$playbook" 2>&1)
	if [ "$?" -eq "0" ]; then
	    if [ "$subcmd" = "test" ]; then
		message="test: $out"; log-ok
	    fi
	    message="$project $playbook PASSED"; log-ok
	    $cmd clean $project
	else
            message="$out\n$marker"; log-err
            rc=1
	fi
    done
done

exit $rc
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# EOF
