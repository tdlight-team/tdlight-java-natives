#!/bin/bash -e
set -e

# Check variables correctness
if [ -z "${IMPLEMENTATION_NAME}" ]; then
	echo "Missing parameter: IMPLEMENTATION_NAME"
	exit 1
fi
if [ -z "${API_TYPE}" ]; then
	echo "Missing parameter: API_TYPE"
	exit 1
fi

cd "./generated-${API_TYPE}/target/apidocs"
find . -name '*.html' -exec sed -i -r 's/<\/title>/<\/title>\n<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\"><style>\n\t#memberSummary_tabpanel{overflow-x: auto;}\n\tli.blockList{overflow-x: auto;}\n\ttd.colLast div{max-width:30vw;}\n\t#search{width: 400px;max-width: 65vw;}\n\t.title,.subTitle,pre,.inheritance,h1,h2,h3,h4,h5,.memberSummary,.memberSignature,.typeSummary,.blockList,.contentContainer{white-space:normal;word-break:break-word;}\n\tul{padding-left:10px}\n<\/style>/' {} \;
git init
git checkout -b "${IMPLEMENTATION_NAME}-${API_TYPE}"
git remote add origin "https://${DOCS_DEPLOY_USERNAME}:${DOCS_DEPLOY_PASSWORD}@git.ignuranza.net/tdlight-team/tdlight-docs"
git config user.email "andrea@warp.ovh"
git config user.name "Andrea Cavalli"
git fetch --all
git reset --soft "origin/${IMPLEMENTATION_NAME}-${API_TYPE}" || true
git add -A
git commit -m "Update javadocs"
git push --set-upstream origin "${IMPLEMENTATION_NAME}-${API_TYPE}"

echo "Done."
exit 0
