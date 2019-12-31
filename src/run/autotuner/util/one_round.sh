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
	echo -n Testing n=$1 m=$2 Results=
	if [ "$1" -le 4  ] ; then read bfs_nt sssp_nt < <(echo 0e1 0e1) ;
	elif [ "$1" -ge 24 ] ; then read bfs_nt sssp_nt < <(echo 0e1 0e1) ;
	elif [ "$2" -le 4  ] ; then read bfs_nt sssp_nt < <(echo 0e1 0e1) ;
	else
	read bfs_nt sssp_nt < <(mpirun -np 16 ../../../graph500_reference_bfs_sssp $1 $2 |& grep 'mean_TEPS' | tr -s ' ' | cut -d' ' -f4 | tr '\n' ' ')
	fi
	echo $bfs_nt $sssp_nt
}

new_target_stat_is_better ()
{
	# $1: bfs_t
	# $2: sssp_t
	# $3: bfs_nt
	# $4: sssp_nt
	# $5: 1 for bfs, 2 for sssp
	if [ "$5" -eq "1" ] ; then
		if teps_a_gt_b $3 $1 ; then true ; else false ; fi
	else
		if teps_a_gt_b $4 $2 ; then true ; else false ; fi
	fi
}

if [ -z "$1" ] ; then
	echo Missing argument: mode
	exit 1
fi

mode=$1
read round n m vnn vpn vnm vpm bfs_t sssp_t < checkpoint$mode

echo Round $round $n $m
echo Offset $vnn $vpn $vnm $vpm
echo Old TEPS: $bfs_t $sssp_t

if [ "$((RANDOM % 4))" -eq '0' ] ; then
	test_run_with_config $((n-vnn)) $m
	if new_target_stat_is_better $bfs_t $sssp_t $bfs_nt $sssp_nt $mode ; then vnn=$((vnn+1)) ; else vnn=$((vnn-1)) ; fi
fi
if [ "$((RANDOM % 4))" -eq '0' ] ; then
	test_run_with_config $((n+vpn)) $m
	if new_target_stat_is_better $bfs_t $sssp_t $bfs_nt $sssp_nt $mode ; then vpn=$((vpn+1)) ; else vpn=$((vpn-1)) ; fi
fi
if [ "$((RANDOM % 4))" -eq '0' ] ; then
	test_run_with_config $n $((m-vnm))
	if new_target_stat_is_better $bfs_t $sssp_t $bfs_nt $sssp_nt $mode ; then vnm=$((vnm+1)) ; else vnm=$((vnm-1)) ; fi
fi
if [ "$((RANDOM % 4))" -eq '0' ] ; then
	test_run_with_config $n $((m+vpm))
	if new_target_stat_is_better $bfs_t $sssp_t $bfs_nt $sssp_nt $mode ; then vpm=$((vpm*2)) ; else vpm=$((vpm-1)) ; fi
fi

round=$((round+1))
n_n=$n
n_m=$m
if [ "$vpn" -gt "$vnn" ] ; then
	if [ "$vpn" -gt 0 ] ; then n_n=$((n+vpn)) ; fi
elif [ "$vpn" -lt "$vnn" ] ; then
	if [ "$vnn" -gt 0 ] ; then n_n=$((n-vnn)) ; fi
fi
if [ "$vpm" -gt "$vnm" ] ; then
	if [ "$vpm" -gt 0 ] ; then n_m=$((m+vpm)) ; fi
elif [ "$vpm" -lt "$vnm" ] ; then
	if [ "$vnm" -gt 0 ] ; then n_m=$((m-vnm)) ; fi
fi

if [ "$vnn" -le 0 ] ; then vnn=1 ; fi
if [ "$vpn" -le 0 ] ; then vpn=1 ; fi
if [ "$vnm" -le 0 ] ; then vnm=1 ; fi
if [ "$vpm" -le 0 ] ; then vpm=1 ; fi

echo Last contest:
test_run_with_config $n_n $n_m
if [ "$n"="$n_n" && "$m"="$n_m" ] ; then
	bfs_t=$(( (bfs_t + bfs_nt) / 2 ))
	sssp_t=$(( (sssp_t + $sssp_nt) / 2 ))
elif new_target_stat_is_better $bfs_t $sssp_t $bfs_nt $sssp_nt $mode ; then
	n=$n_n
	m=$n_m
	bfs_t=$bfs_nt
	sssp_t=$sssp_nt
fi

result="$round $n $m $vnn $vpn $vnm $vpm $bfs_t $sssp_t"
echo New CheckPoint: $result
echo $result > checkpoint${mode}
echo $result >> tune${mode}.log


