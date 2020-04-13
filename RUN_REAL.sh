#!/bin/sh
#
#  Make sure I use the correct shell.
#
#PBS -S /bin/sh
#
#  Give the job a name
# 
#PBS -N "WRF_REAL"
#
#  Specify the project the job belongs to
#
#PBS -A bjerknes
#
#  We want 60 hours on 32 cpu's:
#PBS -l walltime=01:00:00,mppwidth=64
#
#
#  Write the standard output of the job to file 'mpijob.out' (optional)
#PBS -o WRF_REA.out
#
#  Write the standard error of the job to file 'mpijob.err' (optional)
#PBS -e WRF_REA.err
#

# Michel Mesquita - May, 2013
# m2lab.org
#
# ##################################################################################

# USAGE: $ qsub -v EXP="TEST" RUN_REAL.sh

export MPICH_UNEX_BUFFER_SIZE=200000000 #60000000
export MPICH_MAX_SHORT_MSG_SIZE=64000  #128000
export MPICH_PTL_SEND_CREDITS=-1
export MPICH_PTL_UNEX_EVENTS=80000     #20480
export MPICH_PTL_OTHER_EVENTS=2048     #2048
export MPICH_MAX_VSHORT_MSG_SIZE=1024  #1024
export MPICH_PTL_MATCH_OFF=1

ulimit -c unlimited

# Export variables
export PATH=$PATH:/usr/local/bin:/usr/etc:~/bin:./

# load netcdf libraries
module load netcdf

# load WRF
module load WRF/3.3.1

# directory on /work where the job runs
WDIR="/work/$USER/WRF_runs/$EXP/"

echo 'The run directory will be '$WDIR'.'

cd $WDIR

echo 'Running real...'

aprun -B real.exe &> /work/$USER/WRF_runs/$EXP/my_real.log
exit $?
