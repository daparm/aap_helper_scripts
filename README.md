# AAP helper scripts

Some helper scripts for ansible automation platform

## Global usage

Global variable across all shell scripts

```bash
export AAP_URL=https://<aap_url>
export AAP_USER=admin
export AAP_PASSWORD=secret123
```

For more specific introduction either read the script or run it.

## Content

| Script name | Description |
| ----------- | ----------- |
| unique_hosts.sh | The Script will scrape the total hosts of an AAP Instance and returns the number of all hosts and unique hosts |
| unique_hosts_and_groups.sh | The Script will scrape the total hosts of an AAP Instance and displays host vars, group vars and inventory vars (all vars) |