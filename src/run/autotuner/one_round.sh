#!/bin/bash

teps_a_gt_b ()
{
	# $1: a
	# $2: b
	# Return a > b
	return $(awk -v n1="$1" -v n2="$2" 'BEGIN {printf (n1>n2?0:255)}') # 0: success, 255: fail
}

test_run_with_config ()
{
	# $1: new_n
	# $2: new_m
	# Return bfs_TEPS sssp_TEPS
	if [ "$1" -le 4 ] ; then return '0 0' ; fi
	if [ "$2" -le 4 ] ; then return '0 0' ; fi
	ret=$(mpirun -np 16 ../../graph500_reference_bfs_sssp $1 $2 |& grep 'mean_TEPS' | tr -s ' ' | cut -d' ' -f4)
	echo $ret
	return ret
}

new_target_stat_is_better ()
{
	# $1: bfs_t
	# $2: sssp_t
	# $3: bfs_nt
	# $4: sssp_nt
	# $5: 1 for bfs, 2 for sssp
	if [ "$5" -eq 1 ] ; then
		if teps_a_gt_b $3 $1 ; then true ; else false ; fi
	else
		if teps_a_gt_b $4 $2 ; then true ; else false ; fi
	fi
}


read round n m vnn vpn vnm vpm bfs_t sssp_t < checkpoint

#read bfs_nt sssp_nt 
cat <(test_run_with_config $((n-vnn)) $m)
exit 1
if new_target_stat_is_better bfs_t sssp_t bfs_nt sssp_nt $1 ; then vnn=$((vnn+1)) ; else vnn=$((vnn-1)) ; fi
read bfs_nt sssp_nt <(test_run_with_config $((n+vpn)) $m)
if new_target_stat_is_better bfs_t sssp_t bfs_nt sssp_nt $1 ; then vpn=$((vpn+1)) ; else vpn=$((vpn-1)) ; fi
read bfs_nt sssp_nt <(test_run_with_config $n $((m-vnm)))
if new_target_stat_is_better bfs_t sssp_t bfs_nt sssp_nt $1 ; then vnm=$((vnm+1)) ; else vnm=$((vnm-1)) ; fi
read bfs_nt sssp_nt <(test_run_with_config $n $((m+vpm)))
if new_target_stat_is_better bfs_t sssp_t bfs_nt sssp_nt $1 ; then vpm=$((vpm+1)) ; else vpm=$((vpm-1)) ; fi

round=$((round+1))
if [ "$vpn" -gt "$vnn" ] ; then
	if [ "$vpn" -gt 0 ] ; then n=$((n+vpn)) ; fi
elif [ "$vpn" -lt "$vnn" ] ; then
	if [ "$vnn" -gt 0 ] ; then n=$((n-vnn)) ; fi
fi
if [ "$vpm" -gt "$vnm" ] ; then
	if [ "$vpm" -gt 0 ] ; then m=$((m+vpm)) ; fi
elif [ "$vpm" -lt "$vnm" ] ; then
	if [ "$vnm" -gt 0 ] ; then m=$((m-vnm)) ; fi
fi

if [ "$vnn" -le 0 ] ; then vnn=1 ; fi
if [ "$vpn" -le 0 ] ; then vpn=1 ; fi
if [ "$vnm" -le 0 ] ; then vnm=1 ; fi
if [ "$vpm" -le 0 ] ; then vpm=1 ; fi

read bfs_t sssp_t <(test_run_with_config $n $m)
echo $round $n $m $vnn $vpn $vnm $vpm $bfs_t $sssp_t > checkpoint
echo $round $n $m $vnn $vpn $vnm $vpm $bfs_t $sssp_t >> tune$1.log


