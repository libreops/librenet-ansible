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

If it a passwordless user you don't need to pass any flags. If the remote user
requires a password to run the sudo commands, add `--ask-sudo-pass` when
calling a playbook.

## Tags

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

## Usage

### Run all

ansible-playbook -i hosts site.yml -e 'ansible_ssh_port=$SSH_PORT' --ask-vault-pass

### Nginx only changes

Configuration files are located in `roles/nginx/templates/`. Once changed, run:

```
ansible-playbook -i hosts site.yml --tags=nginx -e 'ansible_ssh_port=$SSH_PORT'
```

[vault]: http://docs.ansible.com/playbooks_vault.html "Ansible Vault"
