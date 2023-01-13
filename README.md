# oidc

Activating the connection between GitHub Actions and AWS according to [GitHub][1]
This is required for an effective CI for the creds repo.
The [video][2] provides a detailed explansion how this works.

## Environment Up

```shell
make up
```

## Environment Down

```shell
make down
```

References:
[1]: https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services
[2]: https://youtu.be/k2Tv-EJl7V4
