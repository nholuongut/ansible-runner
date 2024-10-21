#!/bin/bash

marker=$(printf "%80s" | sed "s/ /./g")
cmd=$HOME/bin/arwrapper.bash
subcmd=${1:-run}
rc=0

typeset -A projects
projects=(
    [test_01]="pb-01.yml"
    [test_02]="pb-01.yml"
    [test_03]="pb-01.yml"
)

for project in "${!projects[@]}"; do
    for playbook in ${projects[$project]}; do
	out=$("$cmd" "$subcmd" "$project" "$playbook" 2>&1)
	if [ "$?" -eq "0" ]; then
	    if [ "$subcmd" = "test" ]; then
		printf "[DRY] $out\n"
	    fi
	    printf "[OK]  "$project" "$playbook" PASSED\n"
	    $cmd clean $project
	else
            printf "[ERR] $out\n$marker\n"
            rc=1
	fi
    done
done
exit $rc
