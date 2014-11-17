# Configuration Management of librenet.gr

This repo contains various Ansible scripts that help with maintenance of the
<https://librenet.gr> Diaspora pod.

We try to be as abstract as possible, but this mainly targets our own
infrastructure.

Distributions supported:
- CentOS 7

## Conventions

### Encrypted sensitive data

There is an encrypted file which can be unencrypted with the `--ask-vault-pass`
command. Read more in [Ansible vault][vault].

Needed when no tags are given, or one of the following: `private`, `diaspora`,
`config`.

### Non standard ssh port

For extra security we do not use port 22. When running the playbooks, always
include `-e "ansible_ssh_port=$SSH_PORT"`.

### Deploy user

The tasks are written in a way where sudo is invoked when needed. When running
a playbook, you must ensure that your remote user has sudo privileges to run any
command.

If it is a passwordless user, you don't need to pass any flags. If the remote user
requires a password to run the sudo commands, add `--ask-sudo-pass` when
calling a playbook.

## Playbooks

Inside the `playbooks/` directory, there are the various playbooks.

### site.yml

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
ansible-playbook -i hosts playbooks/restart_services.yml -e "ansible_ssh_port=$SSH_PORT" --tags=diaspora
```

will restart the `unicorn` and `sidekiq` services, as those two tasks have
the `diaspora` tag.

### check_updates.yml

Check if there are any software updates:

```
ansible-playbook -i hosts playbooks/check_updates.yml -e "ansible_ssh_port=$SSH_PORT"
```

### system_update.yml

If you wish to perform a system update you can run:

```
ansible-playbook -i hosts playbooks/system_update.yml -e "ansible_ssh_port=$SSH_PORT"
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
ansible-playbook -i hosts playbooks/maintenance.yml -e "ansible_ssh_port=$SSH_PORT"
```

## Main usage

### Dry run (check)

It is always a good idea to check before you deploy. Just add the `--check` flag
when running a playbook. You can also add `--diff` to see the changed diff.

More info: <http://docs.ansible.com/playbooks_checkmode.html>

### Run all

```
ansible-playbook -i hosts site.yml -e 'ansible_ssh_port=$SSH_PORT' --ask-vault-pass
```

### Nginx only changes

Configuration files are located in `roles/nginx/templates/`. Once changed, run:

```
ansible-playbook -i hosts site.yml --tags=nginx -e 'ansible_ssh_port=$SSH_PORT'
```

[vault]: http://docs.ansible.com/playbooks_vault.html "Ansible Vault"
