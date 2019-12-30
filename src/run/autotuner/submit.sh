#!/bin/bash

#cp -r ../graph500_reference_bfs* ./
qsub -N graph500 -q debug -l nodes=1:ppn=24 -r n -j oe -V run.sh

