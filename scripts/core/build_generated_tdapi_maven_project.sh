#!/bin/bash -e
# MAIN REQUIRED ENVIRONMENT VARIABLES:
#   API_TYPE = <legacy | sealed>

# Check variables correctness
if [ -z "${API_TYPE}" ]; then
	echo "Missing parameter: API_TYPE"
	exit 1
fi

# Print details
echo "Building TdApi package..."
echo "Current directory: $(pwd)"
echo "API type: ${API_TYPE}"

cd ../../generated-"$API_TYPE"

mvn -B "-D${API_TYPE}" clean install

echo "Done."
exit 0
