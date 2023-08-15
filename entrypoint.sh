#!/bin/bash

output_file=./output.log

eval "arr=(${ADDITIONAL_PARAMS})"
# Barbato: modification not to print results for public repos
if [ $REPO_PRIVATE == "true" ]; then
  /app/bin/sast scan create --project-name "${PROJECT_NAME}" -s "." --branch "${BRANCH#refs/heads/}" --scan-info-format json --agent "DEVSEC Github Action" "${arr[@]}" | tee -i $output_file
else
  /app/bin/sast scan create --project-name "${PROJECT_NAME}" -s "." --branch "${BRANCH#refs/heads/}" --scan-info-format json --agent "DEVSEC Github Action" "${arr[@]}" > $output_file
fi

exitCode=${PIPESTATUS[0]}

scanId=(`grep -E '"(ID)":"((\\"|[^"])*)"' $output_file | cut -d',' -f1 | cut -d':' -f2 | tr -d '"'`)

if [ -n "$scanId" ] && [ -n "${PR_NUMBER}" ]; then
  echo "Creating PR decoration for scan ID:" $scanId
  /app/bin/sast utils pr github --scan-id "${scanId}" --namespace "${NAMESPACE}" --repo-name "${REPO_NAME}" --pr-number "${PR_NUMBER}" --token "${GITHUB_TOKEN}"
else
  echo "PR decoration not created."
fi

# Barbato: modification not to print results for public repos
if [ -n "$scanId" ] && [ ${REPO_PRIVATE} == "true" ]; then
  /app/bin/sast results show --scan-id "${scanId}" --report-format markdown 
  cat ./sast_result.md >$GITHUB_STEP_SUMMARY
  rm ./sast_result.md
  echo "cxScanID=$scanId" >> $GITHUB_OUTPUT
fi

if [ $exitCode -eq 0 ]
then
  echo "Scan completed"
else
  echo "Scan Failed" 
  exit $exitCode
fi

