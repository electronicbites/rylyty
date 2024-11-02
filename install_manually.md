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
