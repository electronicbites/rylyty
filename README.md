# Welcome to rylyty


## Getting Started

UNDER CONSTRUCTION: does not work, will be done with vagrant very soon....

best on OS X with rvm (https://rvm.io/rvm/basics/) and homebrew (http://mxcl.github.com/homebrew/)

### Install dependencies on OS X:
```
brew install wget
brew install readline
brew install postgres
```

install a super user
```
psql -U postgres
create role vagrant login superuser createdb valid until 'infinity';
```

### Install dependencies on Debian / Ubuntu:
```
apt-get update
apt-get install wget readline-common postgresql postgresql-client
```

install a super user with your own username
```
sudo -u postgres createuser --superuser $USER
sudo -u postgres psql
```

at the postgresql prompt, set your password;
```
\password postgres // -> postgres
```

in pg_hba.conf check whether user 'postgres' auth is set to md5, not peer
"#local   all             postgres                                peer"
"local   all             postgres                                md5"

```
sudo vim /etc/postgresql/9.1/main/pg_hba.conf
```
create db
```
sudo -u postgres psql
CREATE DATABASE rylyty_development;
```

### Use rvm
   The project currently runs on ruby 1.9.3 and provides a ``.rvmrc`` file
   with a custom gem set.

### Run bundler

```
gem install bundler (only the very first time)
bundle install
```
***bundler 1.2 is needed***

### Create db and seed data
```
rake db:reset db:seed
```

## Git branching strategy/workflow

Create new feature branch starting with feature/
Work an that, commit early, commit often
When you are finished create a pull request
If you want to keep you feature branch uptodate rebase it on master
After someone reviewed it and you have the ok, merge it. Sometimes you need to rebase it on master before
Everything what gets merged into master will automaticly deployed by railsonfire


## Gems && techniques

please dont use every gem which you can google. take a look at http://rubygems.org or http://rubytoolbox.com how active the project is, look at the source and decide afterwards

complex json export: https://github.com/nesquena/rabl
fileupload: https://github.com/thoughtbot/paperclip


## Server

till the private beta, we will use heroku as a deploymentplatform

## Style

Respect the common ruby coding styles and use the new ruby 1.9 hash syntax where possible:
i.e. {foo: 'bar'}

no tabs, 2 spaces

## Workflow

Create feature branches starting with feature/branch-name or hotfix/branch-name for every feature/ticket you are working on. After finishing, create a pull request, after you get the okay to merge your branch, do the merge, watch the server for problems, and delete your branch, at least the remote one.
