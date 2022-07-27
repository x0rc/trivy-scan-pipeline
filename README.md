# Trivy-Scan-Pipeline

[Trivy](https://github.com/aquasecurity/trivy) is a comprehensive security scanner. It is reliable, fast, extremely easy to use, and it works wherever you need it. It is a scanner for vulnerabilities in container images, file systems, and Git repositories, as well as for configuration issues and hard-coded secrets. Here we are using it for scanning the Docker Images

## How to integrate This composite action in your workflow?

- Open Your CI workflow yaml and add the following block after the image build step (or before pushing to ECR step) - minimal configurations

```
- name: Trivy Scan
  id: trivy
  uses: ebot7/trivy-scan-pipeline@main
  with:
    IMAGE: <YOUR-BUILT-IMAGE>
```

## Inputs 

These inputs can be used with the `with` handle 


| Inputs        | Required           | Description  |
| ------------- |:-------------:| :-----|
| `IMAGE`      | Yes | Image built and tagged by the CI step |
| `NOTIFICATION_TYPES`      | No      |   Either `pull_request` or `slack` or both separated by commas (eg: NOTIFICATION_TYPES: pull_request,slack ) |
| `GITHUB_ACCESS_TOKEN` | No      |    Required ONLY IF `NOTIFICATION_TYPES:pull_request` |
|`SLACK_WEBHOOK_URL`|No| Required ONLY IF `NOTIFICATION_TYPES:slack` |


> In order to use this GitHub action, your CI component should have been setup with Github actions.


## Notification Options

1. With Pull Requests

`pull_request` - The developer can define the value as `pull_request` and should provide a `GITHUB_ACCESS_TOKEN` with write permission to the Pull Requests.  Once the image is being scanned, the result will be brought back to the Pull Request (Just like sonar cloud results).

```
# with pull_requests
- name: Trivy Scan
  id: trivy
  uses: ebot7/trivy-scan-pipeline@main
  with:
    IMAGE: <YOUR-DOCKER-IMAGE>
    NOTIFICATION_TYPES: 'pull_request'
    GITHUB_ACCESS_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
```

2. With Slack

### 

`slack` - If the `NOTIFICATION_TYPES` is set to the `slack` along with the `SLACK_WEBHOOK_URL`, everytime an image is scanned, the result will be populated to the defined slack channel.

```
# with pull_requests
- name: Trivy Scan
  id: trivy
  uses: ebot7/trivy-scan-pipeline@main
  with:
    IMAGE: <YOUR-DOCKER-IMAGE>
    NOTIFICATION_TYPES: 'slack'
    SLACK_WEBHOOK_URL: "${{ secrets.SLACK_WEBHOOK }}"
```

Or you can use the both methods above. Values should be separated by a comma.

```
. . . 
		NOTIFICATION_TYPES: 'pull_request,slack'
		GITHUB_ACCESS_TOKEN: "${{ secrets.GITHUB_TOKEN }}"
    SLACK_WEBHOOK_URL: "${{ secrets.SLACK_WEBHOOK }}"
. . .
```

> Note: When using the sensitive information such as `GITHUB_ACCESS_TOKEN` and `SLACK_WEBHOOK_URL`, please use [Github Secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)
>