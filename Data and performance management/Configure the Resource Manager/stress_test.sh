#!/bin/bash
# ------------------------------------------------------------------------------
# Stress test all PDBs using CPU hog script
# ------------------------------------------------------------------------------

PDBs="PLUM JAM JAM0 JAM1 VEGEMITE VEGEMITER"
for pdb in $PDBs
do nohup ./cpu_hog.sh $pdb >/dev/null 2>&1 &
done

exit 0
