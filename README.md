# bootstrap

## System Requirements

* AWS [credentials settings][1]
* `make`
* `podman` or `docker`

## step 0

* AWS S3 Bucket - for Terraform S3 backend

```shell
make step_0
```

## CI bot

bot user for executing GitHub Actions workflows

Resources:

* IAM user with proper permissions and access keys
* Access keys populated as GitHub organization secrets

```shell
make ENV=prod up
```

[1]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html
