# !/bin/bash

if [ $# -eq 0 ]
then
    echo 'ERROR: MISSION USERNAME'
else
    sfdx force:source:deploy -p force-app/ -u $1 -l RunSpecifiedTests -r TestF_PointsService -c -w 60
fi

# TO USE :
# scripts/shell/deployProjectToOrg.sh username