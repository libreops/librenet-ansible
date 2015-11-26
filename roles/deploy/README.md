## Deploy page for librenet.gr

Enable deploy page:

```
ansible-playbook playbooks/deploy.yml -l librenet.gr -t enable
```

Disable deploy page:

```
ansible-playbook playbooks/deploy.yml -l librenet.gr -t disable
```

![Deploy page screenshot](deploy_screenshot.png)
