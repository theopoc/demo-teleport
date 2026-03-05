# demo-teleport

Infrastructure-as-code lab demonstrating **Teleport zero-trust access management** using Vagrant for VM orchestration and Ansible for service provisioning.

## Requirements

- **Vagrant** — VM orchestration
- **Ansible** — Configuration management
- **VirtualBox** — Hypervisor (default provider)
- **mise** (optional) — Tool version management (defined in `.mise.toml`)
- **direnv** (optional) — Environment variable loading (defined in `.envrc`)

## Architecture Diagram

![Teleport Architecture Diagram](assets/architecture-diagram.png)

**Key Points:**
- Operator connects to Proxy via HTTPS/WSS (:443, :3080)
- Proxy communicates with Auth Service via gRPC (:3025)
- Agent establishes reverse tunnel to Proxy (SSH over WSS)
- No external ports exposed on target server


## Installation

### 1. Clone and setup environment

```bash
git clone <repo-url>
cd demo-teleport
direnv allow      # Activate environment variables
```

### 2. Bootstrap VMs and services

```bash
task setup        # Full provisioning (Vagrant + Ansible)
```

This command:
- Creates two Ubuntu 24.04 VMs
- Generates Ansible inventory
- Provisions Bastion with Teleport Auth/Proxy
- Provisions Target with Teleport Agent, Nginx, MySQL

### 3. Verify deployment

```bash
task status                          # Check VM status
task logs:bastion                    # Stream bastion logs
task display-admin-invite:bastion    # Get admin login URL
```

### 4. Access the infrastructure

**Direct SSH (no Teleport needed):**
```bash
vagrant ssh teleport-bastion
vagrant ssh target-server
```

**Via Teleport (after initial setup):**
```bash
tsh login --proxy=192.168.56.10:3080
tsh ssh user@target-server
```

### 5. Cleanup

```bash
task destroy      # Remove VMs and .vagrant directory
```

## References

- [Teleport Documentation](https://goteleport.com/docs/)
- [Vagrant Documentation](https://www.vagrantup.com/docs)
- [Ansible Documentation](https://docs.ansible.com/)

---

**Note**: This is a lab environment with self-signed certificates and pre-shared secrets. Not suitable for production.
