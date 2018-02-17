<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**  *generated with [DocToc](http://doctoc.herokuapp.com/)*

- [Configuration Management of librenet.gr](#configuration-management-of-librenetgr)
  - [Conventions](#conventions)
    - [Encrypted sensitive data](#encrypted-sensitive-data)
      - [Running playbooks](#running-playbooks)
      - [Add more variables](#add-more-variables)
    - [Non standard ssh port](#non-standard-ssh-port)
    - [Deploy user](#deploy-user)
  - [Playbooks](#playbooks)
    - [deploy.yml](#deployyml)
    - [check_updates.yml](#check_updatesyml)
    - [fetch_logs.yml](#fetch_logsyml)
    - [services_restart.yml](#services_restartyml)
    - [services_status.yml](#services_statusyml)
    - [system_update.yml](#system_updateyml)
    - [maintenance.yml](#maintenanceyml)
  - [Specific runs](#specific-runs)
    - [Run all](#run-all)
    - [Nginx only changes](#nginx-only-changes)
    - [Config only changes](#config-only-changes)
    - [Assets only changes](#assets-only-changes)
- [Testing](#testing)
- [Deploying new Diaspora versions](#deploying-new-diaspora-versions)
- [Vagrant](#vagrant)
  - [Requirements](#requirements)
  - [Run](#run)
  - [Configuration](#configuration)
  - [Useful links](#useful-links)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

![Build Status](https://travis-ci.org/librenet/ansible.svg?branch=master)

# Configuration Management of librenet.gr

This repo contains various Ansible scripts that help with maintenance of
the <https://librenet.gr> Diaspora pod.

We try to be as abstract as possible, but this mainly targets our own
infrastructure.

Distributions supported:
- CentOS 7

For testing purposes, a Vagrantfile is provided which emulates the
deployment on a VM. Check the `vagrant/` directory.

It is always a good idea to check before you deploy. Just add the
`--check` flag when running a playbook. You can also add `--diff` to see
the changed diff.

More info: <http://docs.ansible.com/playbooks_checkmode.html>

## Conventions

### Encrypted sensitive data

There is an encrypted private vars file which can be unencrypted with the
`vault-passwd.txt.gpg` file. Read below on how to use it.

#### Running playbooks

Some sensitive files like `private.yml` are encrypted with [ansible-vault][vault].
`vault-passwd.txt.gpg` is automatically decrypted during playbook run.
That saves us time from running `--vault-password-file vault-passwd.txt`
each time. The password is decrypted on the fly without the need to decrypt
to plain text file. It is needed when no tags at all are given, or one of the
following is used: `private`, `diaspora`, `config`.

Read more in [Using PGP To Encrypt The Ansible Vault][vault-blog] and
[How do I store private data in git for Ansible?][private].

#### Add more variables

If you need to add more variables to the encrypted file, you can edit it
with:

```
ansible-vault edit roles/diaspora/vars/private.yml
```

You can't provide the file the password is stored, so manual copy-paste is
needed. Once done, don't forget to push back any changes.

**Note:** Every time you edit the encrypted file, it appears changed even if
you don't make any changes.

### Non standard ssh port

For extra security we do not use port 22. There are two ways to provide
our custom port.

- When running the playbooks, include `-e "ansible_ssh_port=$SSH_PORT"`
- Copy `hosts.example` to `hosts` and edit like `hostname:port`.

The hosts file is excluded from git so that you don't give away the port.

### Deploy user

The tasks are written in a way where sudo is always invoked. When running a
playbook, you must ensure that your remote user has sudo privileges to run any
command.

If it is a passwordless user, you don't need to pass any flags. If the remote
user requires a password to run the sudo commands, add `--ask-sudo-pass` when
calling a playbook.

## Playbooks

Inside the `playbooks/` directory, there are various playbooks for everyday
administrative usage.

The table below summarizes their purposes.

playbook                | description
----------------------- | -----------
`deploy.yml`            | the main playbook which deploys diaspora with its various components
`check_updates.yml`     | checks for system updates without updating
`fetch_logs.yml`        | fetches logs for inspection
`maintenance.yml`       | calls `check_updates.yml`, `system_update.yml` and `services_restart.yml` in that order
`services_restart.yml`  | restarts various services
`services_status.yml`   | checks status of various services
`system_update.yml`     | updates system by running `yum update`

### deploy.yml

The main playbook that is responsible for all the roles.

It deploys a diaspora pod with PostgreSQL on a CentOS 7 server.

Run with:
```
ansible-playbook -i hosts deploy.yml --vault-password-file vault-passwd.txt
```

Supported tags:

```
- diaspora
- config
- unicorn
- sidekiq
- routes
- private
- systemd
- nginx
- yum
- pkg
- epel
- database
- backup
```

### check_updates.yml

Check if there are any software updates. It does not update the system. After
running this playbook you might want to run `system_update.yml` to fully
update your system.

Run with:

```
ansible-playbook -i hosts playbooks/check_updates.yml
```

### fetch_logs.yml

It fetches logs for inspection. Currently included: sidekiq, unicorn.
If you want to add more logs to fetch, edit `playbooks/fetch_logs.yml` and
add another entry below the `with_items` option.

By default, logs are stored in a `downloads/` dir at the root of this repo
which is in `.gitignore`.

Source and destination are defined by variables. If you want to store in a
different location you have to edit them.

Run with:
```
ansible-playbook -i hosts playbooks/fetch_logs.yml
```

### services_restart.yml

Restart main services.

Supported tags:

```
unicorn
sidekiq
mariadb
diaspora
ssh
```

For example:

```
ansible-playbook -i hosts playbooks/restart_services.yml --tags=diaspora
```

will restart the `unicorn` and `sidekiq` services, as those two tasks have
the `diaspora` tag.

### services_status.yml

Check the status of various services.

Supported services: `nginx`, `unicorn`, `sidekiq`, `postgres`, `redis`, `prosody`,
`camo`.

Supported tags:

```
- nginx
- diaspora
- unicorn
- sidekiq
- redis
- postgres
- database
- prosody
- camo
```

Run with:

```
ansible-playbook -i hosts playbooks/services_status.yml
```

### system_update.yml

Perform a system update.

Run with:

```
ansible-playbook -i hosts playbooks/system_update.yml
```

You will be prompted whether to continue or not. Possible answers are `yes`
and `no`, with `no` being the default. To be sure, first run the
`check_updates.yml` to see what updates are available.

### maintenance.yml

Currently has the following playbooks included:

* `check_updates.yml`
* `system_update.yml`
* `services_restart.yml`

Run with:
```
ansible-playbook -i hosts playbooks/maintenance.yml
```

## Specific runs

### Run all

Run all roles:
```
ansible-playbook -i hosts deploy.yml --vault-password-file vault-passwd.txt
```

### Nginx only changes

Configuration files are located in `roles/nginx/templates/`. Once changed, run:

```
ansible-playbook -i hosts deploy.yml --tags=nginx
```

### Config only changes

If you changed something in `diaspora.yml` run the playbook with:

```
ansible-playbook -i hosts deploy.yml --vault-password-file vault-passwd.txt -t config
```

### Assets only changes

If you change/add anything under `app/assets`, run the playbook with:

```
ansible-playbook -i hosts deploy.yml -t assets
```

It will fetch the new code and run the rake task to precompile the assets.

# Testing

There is some minimal testing done. You can run `./bin/ansible-test` locally
and it will test the syntax of `deploy.yml` and all its tasks. Travis is setup
to also test the syntax.

# Deploying new Diaspora versions

In order to deploy a new version, our Diaspora fork should first be updated.

Locally, clone our fork and set a remote to Diaspora upstream:

```bash
git clone git@gitlab.com:hsgr/webops/librenet.gr.git
git remote add upstream https://github.com/diaspora/diaspora.git
```

Diaspora's `master` branch always points to the latest stable release, so we'll
use that to update our fork.

Our base branch which contains all custom changes, is `librenet`. The workflow
to update `librenet` with latest `master` from upstream is:

1. Checkout the `librenet` branch:

    ```
    git checkout librenet
    ```

1. Fetch the upstream master branch:

    ```
    git fetch upstream master
    ```

1. Merge `upstream/master` in `librenet`:

    ```
    git merge upstream/master
    ```

1. Resolve any conflicts, usually in `Gemfile.lock` in which we have added the
   new_relic gem.
1. Add unstaged files:

    ```
    git add file1 file2
    ```

1. Run `git commit` and let Git do its magic
1. Push back to our fork:

    ```
    git push origin librenet
    ```

Now it's time to read [Diaspora's changelog](https://github.com/diaspora/diaspora/blob/develop/Changelog.md)
and check if there are any changes needed to any yaml files or any tasks need
to run manually.

To update librenet.gr with the new version, run the playbook:

```bash
ansible-playbook deploy.yml -t diaspora -l librenet.gr
```

# Vagrant

For testing purposes, a Vagrantfile is provided, so that a staging environment
can be set up.

## Requirements

You must have installed the following software in your local machine:

- [Virtualbox](https://www.virtualbox.org/wiki/Downloads)
- [Vagrant](https://www.vagrantup.com/downloads.html)
- [Ansible](http://www.ansible.com/home)

## Run

**Note:** Before running vagrant you might want to change some of its
configuration. See [configuration](#configuration) for available settings.

```
# Clone this repo
git clone https://github.com/librenet/ansible diaspora_ansible

# Change to root directory
cd diaspora_ansible/

# Edit Vagrantfile to match your setup and start vagrant
vagrant up
```

The first run will take some time as it will first download the base CentOS7
image and then run ansible.

For consecutive runs, run:
```
vagrant provision
```

See [useful links](#useful-links) for more vagrant commands.

## Configuration

Current Vagrantfile assumes certain things. You might want to change them
to match your own setup.

`ansible.playbook` (string): path to the playbook to run (relative/absolute).

`ansible.vault_password_file` (string): path to the `vault-passwd.txt` (relative/absolute).

`ansible.extra_vars = { sitename: "staging.librenet.local" }` (dictionary):

Diaspora sets the FQDN in the database via `diaspora.yml`. Setting this
extra variable in Vagratfile, you can bypass the one set in
`roles/diaspora/defaults/main.yml` and `roles/nginx/vars/main.yml`, so that
you have a separate FQDN for staging. After successful provisioning, you
can set in your `/etc/hosts`:

```
192.168.33.10 staging.librenet.local
```

Point your web browser to `staging.librenet.local` and test your deployment.

## Useful links

Some useful vagrant links:

- <https://docs.vagrantup.com/v2/provisioning/ansible.html>
- <https://docs.vagrantup.com/v2/cli/index.html>

[vault]: http://docs.ansible.com/playbooks_vault.html "Ansible Vault"
[private]: http://ansiblecookbook.com/html/en.html#how-do-i-store-private-data-in-git-for-ansible
[vault-blog]: https://blog.andrewlorente.com/p/using-pgp-to-encrypt-the-ansible-vault
