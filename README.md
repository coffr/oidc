# bootstrap

## System Requirements

* AWS [credentials settings][1]
* `make`
* `podman` or `docker`

## CI bot

bot user for executing GitHub Actions workflows

Resources:

* IAM user with proper permissions and access keys
* Access keys populated as GitHub organization secrets

```shell
make ENV=prod up
```

## OIDC

Activating the connection between GitHub Actions and AWS according to [GitHub][1]
This is required for an effective CI for the creds repo.
The [video][2] provides a detailed explansion how this works.

[1]: https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html

[2]: https://youtu.be/k2Tv-EJl7V4
