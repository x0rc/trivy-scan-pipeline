#!/usr/bin/env bash

echo -e "---\n### $test_result_emoji Test Results  \n :whale: - ${IMAGE}  \n| Severity  | Number of Vulnerabilities|\n| ------------- | ------------- |\n| $critical_emoji Critical    | $critical_vulnerability_count  |\n| $high_emoji High        | $high_vulnerability_count  |\n" >> pr_body

echo  ":memo: [View the Full Report](${GITHUB_ACTION_URL})" >> pr_body

# Reset the variable
echo 'SUMMARY_OF_THE_SCAN=' >> $GITHUB_ENV

echo 'SUMMARY_OF_THE_SCAN<<EOF' >> $GITHUB_ENV
cat pr_body >> $GITHUB_ENV
echo 'EOF' >> $GITHUB_ENV