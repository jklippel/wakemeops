# WakeMeOps

[![GitHub](https://img.shields.io/badge/GitHub-100000?style=for-the-badge&logo=github&logoColor=white)](https://github.com/upciti/wakemeops)
[![GitLab](https://img.shields.io/badge/GitLab-330F63?style=for-the-badge&logo=gitlab&logoColor=white)](https://gitlab.com/upciti/wakemeops)

Generate Debian packages for common binary tools such as bat, fd, exa, kubectl, terraform, ...
using [ops2deb](https://github.com/upciti/ops2deb).

## Projects

- [ops2deb](https://github.com/upciti/ops2deb)
- [wakemebot](https://github.com/upciti/wakemebot)

## How to use-it

### Configuration

```shell
curl https://gitlab.com/upciti/wakemeops/-/snippets/2189589/raw/main/install.sh | sudo bash -s devops secops terminal
```

### Install package

```console
sudo apt-get update
sudo apt-get install bat
```
