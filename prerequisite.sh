#!/usr/bin/env bash

wget --no-verbose https://github.com/aquasecurity/trivy/releases/download/v0.18.3/trivy_0.18.3_Linux-64bit.deb
sudo dpkg -i trivy_0.18.3_Linux-64bit.deb 2> /dev/null

trivy image --format template --template '{{- $critical := 0 }}{{- $high := 0 }}{{- range . }}{{- range .Vulnerabilities }}{{- if  eq .Severity "CRITICAL" }}{{- $critical = add $critical 1 }}{{- end }}{{- if  eq .Severity "HIGH" }}{{- $high = add $high 1 }}{{- end }}{{- end }}{{- end }}Critical: {{ $critical }}, High: {{ $high }}' ${{ env.DOCKER_IMAGE_TO_SCAN }} | grep -i "Critical:" > scan_results 

content=$(cat scan_results)

IFS=, read var1 var2 <<< $content
IFS=: read critical1 critical2 <<< $var1
IFS=: read high1 high2 <<< $var2

slack_attachment_bar_color="#0CFE6B" # green
summary_report_msg="No Vulnerabilities Found, Everything looks Good!"

critical_emoji=":red_circle:"
if [ "$critical2" -eq 0 ]; then
critical_emoji=":white_check_mark:"
else
slack_attachment_bar_color="#FE360C" # red
summary_report_msg="CRITICAL Vulnerabilities Found!, Fix Immediately!!!"
fi

high_emoji=":large_orange_diamond:"
high_vulnerabilities_found="false"
if [ "$high2" -eq 0 ]; then
high_emoji=":white_check_mark:"
elif [ $critical2 -eq 0 ] && [ $high2  -nq 0 ]; then
high_vulnerabilities_found="true"
slack_attachment_bar_color="#FBB215" # orange\
summary_report_msg="HIGH Vulnerabilities Found!, Have a Look!"
echo "HIGH_VULNERABILITIES_FOUND=${high_vulnerabilities_found}" >> $GITHUB_ENV                        
fi          

test_result_emoji=":boom:"
critical_vulnerabilities_found="false"
if [ $critical2 -eq 0 ] && [ $high2  -eq 0 ]; then
test_result_emoji=":eight_spoked_asterisk:"
else
critical_vulnerabilities_found="true"
echo "CRITICAL_VULNERABILITIES_FOUND=${critical_vulnerabilities_found}" >> $GITHUB_ENV          
fi 

echo "CRITICAL_NUMBER_OF_VULNERABILITIES=${critical2}" >> $GITHUB_ENV
echo "HIGH_NUMBER_OF_VULNERABILITIES=${high2}" >> $GITHUB_ENV

echo "CRITICAL_EMOJI=${critical_emoji}" >> $GITHUB_ENV
echo "HIGH_EMOJI=${high_emoji}" >> $GITHUB_ENV
echo "TEST_RESULT_EMOJI=${test_result_emoji}" >> $GITHUB_ENV
echo "SLACK_ATTACHMENT_BAR_COLOR=${slack_attachment_bar_color}" >> $GITHUB_ENV
echo "SUMMARY_REPORT_MSG=${summary_report_msg}" >> $GITHUB_ENV
echo "GITHUB_ACTION_URL=${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}" >> $GITHUB_ENV