# perfsonar-archive-docker

Requirements

- Docker
```shell
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
sudo systemctl start docker
```

Running

```shell
git clone https://github.com/DanielNeto/perfsonar-archive-docker.git
cd perfsonar-archive-docker

docker compose --profile setup up -d

docker compose --profile run up -d
```