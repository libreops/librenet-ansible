# Configuration Management of librenet.gr

This repo contains various Ansible scripts that help with maintenance of the
<https://librenet.gr> Diaspora pod.

We try to be as abstract as possible, but this mainly targets our own
infrastructure.

Distributions supported:
- CentOS 7

## Conventions

### Encrypted sensitive data

There is an encrypted vars file which can be unencrypted with the
`vault-passwd.txt` file. Below are two options you'll want to use it.

#### Running playbooks

You first need to unencrypt `vault-passwd.txt.gpg` using your gpg key
(if you are one of librenet.gr's podmins that is) and then use
`--vault-password-file vault-passwd.txt`. For extra security, after
successful deployment, you may want to remove the plain text file.

It is needed when no tags at all are given, or one of the following is used:
`private`, `diaspora`, `config`.

Read more in [Ansible vault][vault] and [How do I store private data in git for Ansible?][private].

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

The tasks are written in a way where sudo is invoked when needed. When running
a playbook, you must ensure that your remote user has sudo privileges to run any
command.

If it is a passwordless user, you don't need to pass any flags. If the remote user
requires a password to run the sudo commands, add `--ask-sudo-pass` when
calling a playbook.

## Playbooks

Inside the `playbooks/` directory, there are the various playbooks.

### deploy.yml

The main playbook that is responsible for all the roles.
Currently we have the following supported tags:
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
- mycnf
```

### restart_services.yml

Restart main services. Supported tags are:

```
unicorn
sidekiq
ssh
mariadb
diaspora
```

For example:

```
ansible-playbook -i hosts playbooks/restart_services.yml --tags=diaspora
```

will restart the `unicorn` and `sidekiq` services, as those two tasks have
the `diaspora` tag.

### check_updates.yml

Check if there are any software updates:

```
ansible-playbook -i hosts playbooks/check_updates.yml
```

### system_update.yml

If you wish to perform a system update you can run:

```
ansible-playbook -i hosts playbooks/system_update.yml
```

You will be prompted whether to continue or not. Possible answers are `yes`
and `no`, with `no` being the default. To be sure, first run the
`check_updates.yml` to see what updates are available.

### maintenance.yml

Currently has the two following playbooks included:

* `system_update.yml`
* `restart_services.yml`

Run with:
```
ansible-playbook -i hosts playbooks/maintenance.yml
```

## Main usage

### Dry run (check)

It is always a good idea to check before you deploy. Just add the `--check` flag
when running a playbook. You can also add `--diff` to see the changed diff.

More info: <http://docs.ansible.com/playbooks_checkmode.html>

### Run all

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

---
[vault]: http://docs.ansible.com/playbooks_vault.html "Ansible Vault"
[private]: http://ansiblecookbook.com/html/en.html#how-do-i-store-private-data-in-git-for-ansible
