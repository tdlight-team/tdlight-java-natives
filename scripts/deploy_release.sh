#!/bin/bash -e
cd ../generated

mvn -DpushChanges=false -DlocalCheckout=true -DpreparationGoals=initialize release:prepare release:perform -B

echo "Done."
exit 0
