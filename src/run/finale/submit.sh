#!/bin/bash

if [ -z "$1" ] ; then
	echo Missing mode
	exit 1
fi

term=$1
qsub -N g500t$term -q debug -l nodes=1:ppn=24 -r n -j oe -V ./run$term.sh

