FROM ubuntu:14.04

ARG RUBY_VERSION=2.1.10
ARG PG_MAJOR=12
ARG NODE_MAJOR=16
ARG BUNDLER_VERSION=1.7.15
ARG YARN_VERSION=1.17.3

# Add PostgreSQL to sources list
# RUN curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
#     && echo 'deb https://apt-archive.postgresql.org/pub/repos/apt stretch-pgdg main' $PG_MAJOR > /etc/apt/sources.list.d/pgdg.list

# # Add Yarn to the sources list
# RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
#     && echo 'deb http://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list

# Configure bundler and PATH
ENV LANG=C.UTF-8 \
    GEM_HOME=/bundle \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
ENV BUNDLE_PATH=$GEM_HOME
ENV BUNDLE_APP_CONFIG=$BUNDLE_PATH \
    BUNDLE_BIN=$BUNDLE_PATH/bin
ENV PATH=/app/bin:~/.rbenv/bin:~/.rbenv/shims/:$BUNDLE_BIN:$PATH
ENV RUBY_VERSION=$RUBY_VERSION

# Set environment variables
ENV RAILS_ENV=production \
    APP_HOME=/app

# Install Node.js 14 and other necessary packages
RUN apt-get update -qq && \
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
    zlib1g-dev \
    git && \
    curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    apt-get install -y --force-yes  nodejs && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

SHELL ["/bin/bash", "-c"]
RUN git clone https://github.com/rbenv/rbenv.git ~/.rbenv
RUN ["/bin/bash", "-c", "~/.rbenv/bin/rbenv init"]

RUN git clone https://github.com/rbenv/ruby-build.git /root/.rbenv/plugins/ruby-build
RUN ~/.rbenv/bin/rbenv install $RUBY_VERSION && ~/.rbenv/bin/rbenv global $RUBY_VERSION

# # Set working directory
WORKDIR $APP_HOME
# # Copy application code to the container
COPY . .

# # # Install bundler and application gems
RUN  ~/.rbenv/shims/gem install bundler -v $BUNDLER_VERSION && \
    bundle install --binstubs --verbose --retry=3 --without='development test'

RUN /root/.rbenv/versions/2.1.10/bin/ruby /bundle/bin/rake assets:precompile


# a writable tmp dir even in Lambda situation
RUN ln -s /tmp /app/tmp

EXPOSE 3000

# # CMD ["bundle","exec","rails","server"]
