#!/bin/bash

teps_a_gt_b ()
{
	# $1: a
	# $2: b
	# Return a > b
	return $(awk -v n1="$1" -v n2="$2" 'BEGIN {printf (n1>n2?0:255)}') # 0: success, 255: fail
}

new_target_stat_is_better ()
{
	if teps_a_gt_b $1 $2 ; then true ; else false ; fi
}

if new_target_stat_is_better $1 $2 ; then
	echo hi
fi


