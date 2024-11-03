ssh -i /Users/nexus/.ssh/rylyty_do_rsa root@207.154.208.187


````bash
export RUBY_VERSION=2.1.10
export NODE_MAJOR=14
export BUNDLER_VERSION=1.7.15

apt-get update -qq && \
    apt-get install -y \
    curl \
    gnupg \
    build-essential \
    libpq-dev \
    libxml2 \
    libxml2-dev \
    libxslt1-dev \
    gcc \
    g++ \
    make \
    wget \
    unzip \
    readline-common \
    postgresql-client \
    postgresql-12 \
    zlib1g-dev \
    git && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y --force-yes  nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

git clone https://github.com/rbenv/rbenv.git ~/.rbenv && ~/.rbenv/bin/rbenv init
git clone https://github.com/rbenv/ruby-build.git "$(~/.rbenv/bin/rbenv root)"/plugins/ruby-build && ~/.rbenv/bin/rbenv install $RUBY_VERSION

~/.rbenv/bin/rbenv global $RUBY_VERSION
~/.rbenv/shims/gem install bundler -v $BUNDLER_VERSION
mkdir /app
```

scp -i /Users/nexus/.ssh/rylyty_do_rsa rylyty-main.zip  root@207.154.208.187:/app/rylyty-main.zip
ssh -i /Users/nexus/.ssh/rylyty_do_rsa root@207.154.208.187


```bash

export RUBY_VERSION=2.1.10
export NODE_MAJOR=14
export BUNDLER_VERSION=1.7.15

pg_ctlcluster 12 main start
systemctl status postgresql.service
sudo -u postgres psql postgres
```

````SQL
CREATE ROLE rylyty LOGIN PASSWORD 'rylyty' superuser inherit CREATEDB VALID UNTIL 'infinity';
create database rylyty  with encoding='UTF8' owner=rylyty  CONNECTION LIMIT=-1;
```

```bash

cd /app
unzip rylyty-main.zip
cd rylyty-main
bundle install --binstubs --verbose --retry=3 --without='development test'
bundle exec rake assets:precompile

```

zed  -i /Users/nexus/.ssh/rylyty_do_rsa ssh://root@207.154.208.187/app/rylyty-main



```bash
cd /Users/nexus/Documents/_work/rylyty/rylyty-rails
doctl auth switch --context myteam
doctl registry login
doctl registry repository list-v2
```

```bash
doctl kubernetes options sizes
doctl kubernetes cluster create rylyty-cluster \
  --auto-upgrade=true \
  --region=fra1\
  --node-pool="name=rylyty-node-pool;count=1;size=s-2vcpu-2gb"
doctl registry kubernetes-manifest | k apply -f -
k patch serviceaccount default -p '{"imagePullSecrets": [{"name": "registry-electronicbites"}]}'
```

nginx controller

```bash
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx --set controller.publishService.enabled=true
kubectl --namespace default get services -o wide -w nginx-ingress-ingress-nginx-controller
```
# 209.38.184.229
certmanager

```bash
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.yaml
```


api gets build by github actions

```bash
docker buildx build --platform linux/amd64 -f Dockerfile .
# done by github
# docker tag vimantic-frontend registry.digitalocean.com/electronicbites/vimantic-frontend
# docker push registry.digitalocean.com/electronicbites/vimantic-frontend
```

```bash
kubectl apply -f kubernetes/rylylty-relaunch.yml
k port-forward $(k get pod --selector="name=postgres" --output jsonpath='{.items[0].metadata.name}') 8080:5432

pg_restore --verbose --clean --no-acl --no-owner -h localhost -U rylyty -d rylyty -p 8080 ~/Documents/_work/rylyty/docs/170113.dump
```

https://rylyty.electronicbites.com/cockpit/

https://209.38.184.229/cockpit/

https://rylyty.electronicbites.com/cockpit/
