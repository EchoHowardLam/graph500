#!/bin/bash
#
### The shell you want to use

#PBS -S /bin/bash
### The competition queue
### Max resources: 1 node, 24 core, 30 min of running time
#PBS -q debug

cd $PBS_O_WORKDIR

mpirun -np 16 ../../graph500_reference_bfs_sssp 17 251

