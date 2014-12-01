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

# Change to vagrant directory
cd diaspora_ansible/vagrant/

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

`ansible.inventory_path` (string): path to the inventory file (relative/absolute).

`ansible.limit` (string): limit playbook to run only on a particular host.
This is defined in the hosts file. Use in conjuction with the IP that is set up
in Vagrantfile.

For example, `hosts` file should include:
```
diaspora_staging ansible_ssh_host=192.168.33.10
```

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
