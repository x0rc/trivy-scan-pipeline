#!/usr/bin/env bash
wget --no-verbose https://github.com/aquasecurity/trivy/releases/download/v0.33.0/trivy_0.33.0_Linux-64bit.deb
sudo dpkg -i trivy_0.33.0_Linux-64bit.deb 2> /dev/null


if [ "$FULL_REPORT" = "TRUE" ]; then
    trivy image ${DOCKER_IMAGE_TO_SCAN}
else
    trivy image --format template --template '{{- $critical := 0 }}{{- $high := 0 }}{{- range . }}{{- range .Vulnerabilities }}{{- if  eq .Severity "CRITICAL" }}{{- $critical = add $critical 1 }}{{- end }}{{- if  eq .Severity "HIGH" }}{{- $high = add $high 1 }}{{- end }}{{- end }}{{- end }}Critical: {{ $critical }}, High: {{ $high }}' ${DOCKER_IMAGE_TO_SCAN} | grep -i "Critical:" > scan_results 

    content=$(cat scan_results)

    IFS=, read var1 var2 <<< $content
    IFS=: read critical_text critical_vulnerability_count <<< $var1
    IFS=: read high_text high_vulnerability_count <<< $var2

    slack_attachment_bar_color="#0CFE6B" # green
    summary_report_msg="No Vulnerabilities Found!"

    critical_emoji=":red_circle:"
    if [[ $critical_vulnerability_count -eq 0 ]]; then
        critical_emoji=":white_check_mark:"
    else
        slack_attachment_bar_color="#FE360C" # red
        summary_report_msg="CRITICAL Vulnerabilities Found!"
    fi

    high_emoji=":large_orange_diamond:"
    high_vulnerabilities_found="false"
    if [[ $high_vulnerability_count -eq 0 ]]; then
        high_emoji=":white_check_mark:"    
    elif [[ $critical_vulnerability_count -eq 0 ]] && [[ $high_vulnerability_count  -ne 0 ]]; then
        
        high_vulnerabilities_found="true"
        slack_attachment_bar_color="#FBB215" # orange\
        summary_report_msg="HIGH Vulnerabilities Found!"
        echo "HIGH_VULNERABILITIES_FOUND=${high_vulnerabilities_found}" >> $GITHUB_ENV
    fi          

    test_result_emoji=":boom:"
    critical_vulnerabilities_found="false"

    if [[ $critical_vulnerability_count -eq 0 ]] && [[ $high_vulnerability_count  -eq 0 ]]; then
        test_result_emoji=":eight_spoked_asterisk:" 
    else
        critical_vulnerabilities_found="true"
        echo "CRITICAL_VULNERABILITIES_FOUND=${critical_vulnerabilities_found}" >> $GITHUB_ENV 
    fi 

    echo "CRITICAL_NUMBER_OF_VULNERABILITIES=${critical_vulnerability_count}" >> $GITHUB_ENV
    echo "HIGH_NUMBER_OF_VULNERABILITIES=${high_vulnerability_count}" >> $GITHUB_ENV

    echo "CRITICAL_EMOJI=${critical_emoji}" >> $GITHUB_ENV
    echo "HIGH_EMOJI=${high_emoji}" >> $GITHUB_ENV
    echo "TEST_RESULT_EMOJI=${test_result_emoji}" >> $GITHUB_ENV
    echo "SLACK_ATTACHMENT_BAR_COLOR=${slack_attachment_bar_color}" >> $GITHUB_ENV
    echo "SUMMARY_REPORT_MSG=${summary_report_msg}" >> $GITHUB_ENV
    echo "GITHUB_ACTION_URL=${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}" >> $GITHUB_ENV
fi
