# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Demo Teleport** is an infrastructure-as-code lab that demonstrates Teleport access management. It uses **Vagrant** for VM orchestration and **Ansible** for service provisioning across two VMs:
- **teleport-bastion**: Auth/Proxy server (Teleport control plane)
- **target-server**: Services host (Nginx + MySQL + Teleport Agent)

The lab provides hands-on experience with Teleport's zero-trust access model using SSH, Apps, and Database protocol.

## Common Commands

All development tasks are defined in `Taskfile.yml` using the `task` runner. Run `task --list` to see all available commands.

### Setup & Teardown
```bash
task setup        # Full bootstrap (Vagrant + Ansible provisioning)
task destroy      # Remove all VMs and .vagrant directory
task status       # Show vagrant status
```

### Monitoring & Access
```bash
task logs:bastion              # Stream Teleport logs from bastion
task logs:target               # Stream Teleport logs from target
task display-admin-invite:bastion  # Show admin login URL for web UI
```

### Direct VM Access
Vagrant automatically creates provisioned VMs. After `task setup`:
```bash
vagrant ssh teleport-bastion   # SSH directly into bastion
vagrant ssh target-server      # SSH directly into target
```

## Architecture

### Deployment Flow
1. **Vagrant** (`Vagrantfile`) creates two Ubuntu 24.04 VMs with static IPs:
   - Bastion: `192.168.56.10`
   - Target: `192.168.56.11`

2. **Ansible** (`ansible/bastion.yml` and `ansible/target.yml`) provisioned by Vagrant:
   - Bastion playbook: Deploys `teleport-bastion` role
   - Target playbook: Deploys `nginx`, `mysql`, and `teleport-agent` roles in sequence

3. **Role Dependencies**:
   - Bastion initializes first (generates auth tokens, sets up proxy)
   - Target then joins bastion using pre-shared join token
   - Token is stored in `.envrc` and hardcoded in Taskfile.yml for this lab context

### Key Services

#### Teleport Bastion (`ansible/roles/teleport-bastion/`)
- Port 3080: Web UI (self-signed HTTPS)
- Port 3025: Auth service
- Port 3024: Proxy service
- Generated admin invite: `/tmp/admin-invite.txt` on bastion VM
- Join token: `a373a1c1d9cb7cc343d149402029dbb6`

#### Target Server (`ansible/roles/teleport-agent/`, `nginx/`, `mysql/`)
- **Nginx**: Port 80 (static homepage, proxied via Teleport Apps protocol)
- **MySQL**: Port 3306 (provisioned users: `alice`/`alice-password`, `teleport_admin`)
- **Teleport Agent**: SSH and database service registration
- Database `labdb` created for testing

### Ansible Inventory
Located in `ansible/inventory/hosts.yml`:
- Static IP mapping for both VMs
- SSH key path: `.vagrant/machines/<vm>/virtualbox/private_key`
- Vagrant user credentials for provisioning

### Configuration Templates
Ansible uses Jinja2 templates in role `templates/` directories:
- `teleport.yaml.j2`: Bastion Teleport config (uses `{{ ansible_host }}` for VM IP)
- `teleport-agent.yaml.j2`: Agent config (uses `{{ bastion_ip }}` passed as variable)
- Service templates are rendered during provisioning

## Environment & Tools

### VM Access via Vagrant
Direct SSH access to VMs for debugging:
```bash
vagrant ssh teleport-bastion    # Access bastion directly
vagrant ssh target-server       # Access target directly
```
No Teleport authentication needed for direct Vagrant SSH access.

### Dependencies
- **Vagrant**: VM management (must be installed)
- **Ansible**: Configuration provisioning (must be installed)
- **VirtualBox**: Default provider for Vagrant (required)

### Tool Management
- **mise** (`.mise.toml`): Manages `jq` and `task` versions
- **direnv** (`.envrc`): Loads environment variables and runs `mise install`
  - Required exports: `TELEPORT_VERSION`, `BASTION_VM`, `TARGET_VM`, `VM_CPUS`, `VM_MEM`, `VM_DISK`, `UBUNTU_IMAGE`
  - Run `direnv allow` after cloning to activate

### Configuration
- **Taskfile.yml**: All tasks (French labels) with VM resource variables: `VM_CPUS` (default 2), `VM_MEM` (default 2048)
- **Vagrantfile**: Two VM definitions; provisioning triggered via Ansible
- **ansible/ansible.cfg**: SSH pipelining, smart fact gathering, no host key checking for lab environment

## Project Structure

```
demo-teleport/
├── Taskfile.yml              # Task definitions (task runner)
├── Vagrantfile               # Vagrant VM configuration
├── .envrc                    # direnv configuration (sets TELEPORT_VERSION, VM resources)
├── .mise.toml                # Tool versions (jq, task)
├── ansible/
│   ├── ansible.cfg           # Ansible settings
│   ├── bastion.yml           # Bastion playbook (entry point for that VM)
│   ├── target.yml            # Target playbook (entry point for that VM)
│   ├── inventory/
│   │   └── hosts.yml         # Static inventory (IPs, SSH keys)
│   └── roles/
│       ├── teleport-bastion/ # Auth + Proxy + initialization
│       │   ├── tasks/
│       │   │   └── main.yml
│       │   ├── templates/
│       │   │   └── teleport.yaml.j2
│       │   └── files/
│       ├── teleport-agent/   # SSH + App + DB service registration
│       │   ├── tasks/
│       │   │   └── main.yml
│       │   └── templates/
│       │       └── teleport-agent.yaml.j2
│       ├── nginx/            # Web server + homepage
│       │   ├── tasks/
│       │   │   └── main.yml
│       │   ├── templates/
│       │   └── files/
│       └── mysql/            # Database setup + user provisioning
│           └── tasks/
│               └── main.yml
└── .vagrant/                 # Vagrant state (generated, git-ignored)
```

## Key Implementation Notes

1. **Vagrant Provisioning**: Both VMs run Ansible playbooks during `vagrant up`. The bastion must finish provisioning before the target can fully register (they run in parallel but the target waits for bastion's IP via `hostvars`).

2. **Dynamic IP Retrieval**:
   - Bastion playbook uses `ansible_facts['eth1']['ipv4']['address']` to get VM IP
   - Target playbook retrieves bastion IP from `hostvars.bastion_ip` (set during bastion provisioning)

3. **Join Token**: Pre-shared in the lab (`a373a1c1d9cb7cc343d149402029dbb6`). In production, this would be generated dynamically.

4. **Admin Access**: Web UI invite link is generated and stored in `/tmp/admin-invite.txt` on bastion for initial login.

5. **Test Database**: MySQL includes `labdb` with a `messages` table for Teleport database access testing.

## Documentation & References

### Teleport Documentation
Access Teleport documentation via Claude Code MCP context7:
```
Query: "Teleport MySQL TLS configuration" or relevant topic
Library: /gravitational/teleport (high reputation, 7066 code snippets)
```
Use this to find official Teleport config examples and best practices for:
- Database service configuration
- Proxy service setup
- TLS and certificate handling
- Database protocol specifics

## Debugging Tips

- **VM Won't provision**: Check `vagrant status`. If stuck, run `vagrant destroy -f && task setup`.
- **Logs**: Use `task logs:bastion` or `task logs:target` to stream service logs.
- **SSH Access**: Once provisioned, `vagrant ssh teleport-bastion` and `vagrant ssh target-server` work without needing Teleport.
- **Admin Invite**: Check `task display-admin-invite:bastion` if you've lost the URL.
- **Service Check**: On target VM: `sudo systemctl status teleport`, `sudo systemctl status mysql`, `sudo systemctl status nginx`.
- **Teleport Config**: Use context7 to verify configuration syntax and options before applying changes.
