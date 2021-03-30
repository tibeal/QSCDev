# !/bin/bash

if [ $# -eq 0 ]
then
    echo 'ERROR: MISSION USERNAME'
else
    sfdx force:source:deploy -p force-app/ -u $1

    sfdx force:apex:test:run -y -t TestF_PointsService -u $1
fi

#TO USE :
# scripts/shell/deployProjectToOrg.sh username