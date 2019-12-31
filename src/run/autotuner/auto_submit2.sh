#!/bin/bash

term=2

for i in {1..8}; do
	while grep -E "g500t$term.*[RQ] debug" <(qstat) &> /dev/null ; do sleep 30 ; done
	qsub -N g500t$term -q debug -l nodes=1:ppn=24 -r n -j oe -V ./util/run$term.sh
	sleep 1800;
done

