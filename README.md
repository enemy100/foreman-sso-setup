# Foreman SSO Setup

This project automates the Single Sign-On (SSO) configuration between Foreman and Keycloak, including user, group, role, and security policy management. It's designed to work with an existing Foreman installation (see [Foreman-deploy](https://github.com/enemy100/Foreman-deploy) for Foreman installation).

## Overview

The project uses Ansible to automate the installation and configuration of Keycloak as an identity provider for Foreman, implementing:

- Keycloak installation and configuration
- Foreman integration via OpenID Connect
- User, group, and role management
- Security and password policies
- Automated integration tests

## Prerequisites

- Ansible 2.9+
- Foreman installed and configured (using [Foreman-deploy](https://github.com/enemy100/Foreman-deploy))
- Root/sudo access to the server
- Valid SSL certificates (or self-signed for development)

### Installing Required Collections

Before running the playbook, install the required Ansible collections:

```bash
ansible-galaxy collection install -r requirements.yml
```

This will install all necessary collections with versions compatible with your Ansible installation.

## Project Structure

```
foreman-sso-setup/
├── .github/
│   └── workflows/
├── docs/
├── host_vars/
│   └── foreman_vars.yml
├── roles/
│   └── keycloak_setup/
│       ├── defaults/
│       │   └── main.yml
│       ├── tasks/
│       │   ├── main.yml
│       │   ├── java.yml
│       │   ├── install.yml
│       │   ├── configure.yml
│       │   ├── users.yml
│       │   ├── groups.yml
│       │   ├── roles.yml
│       │   ├── password_policy.yml
│       │   ├── themes.yml
│       │   └── verify.yml
│       └── templates/
│           └── keycloak.service.j2
├── inventory.yml
├── requirements.yml
├── README.md
├── site.yml
└── test_integration.yml
```


## Configuration

1. Configure variables in `host_vars/foreman_vars.yml` or use the defaults from `roles/keycloak_setup/defaults/main.yml`:
   ```yaml
   keycloak_version: "21.1.1"
   keycloak_admin_user: "admin"
   keycloak_admin_password: "your-secure-password"
   keycloak_https_port: 8443
   foreman_realm_name: "foreman"
   foreman_client_id: "foreman"
   ```

2. Adjust user, group, and role settings as needed.

3. Ensure `requirements.yml` includes all necessary collections:
   ```yaml
   collections:
     - name: community.general
       version: ">=7.0.0,<8.0.0"  # Compatible with Ansible 2.14
     - name: ansible.posix
       version: ">=1.4.0,<2.0.0"
     - name: community.crypto
       version: ">=2.0.0,<3.0.0"
   ```

## Manual Installation

Clone this repository and run the playbook:

```bash
git clone https://github.com/enemy100/foreman-sso-setup.git
cd foreman-sso-setup
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventory.yml site.yml
```

## Local Installation (Same Server)

If you want to install Keycloak on the same server where you're running Ansible:

1. Update your inventory to use local connection:
   ```ini
   [foreman]
   foremanserver.mydomain.com ansible_connection=local
   ```

2. Run the playbook:
   ```bash
   ansible-playbook -i inventory.yml site.yml
   ```

## Inventory Example

Your `inventory.yml` should look like one of these examples:

### Remote Server Installation
For installation on a remote server:

```ini
[foreman]
foremanserver.mydomain.com ansible_host=192.168.2.1
```

- `foremanserver.mydomain.com` is the FQDN used for SSO/certificates.
- `ansible_host` is the IP or DNS of the target server.
- By default, Ansible will connect as root (if you run `ansible-playbook` as root or specify `-u root`).

### Local Installation
For installation on the same server where you're running Ansible:

```ini
[foreman]
foremanserver.mydomain.com ansible_connection=local
```

## Integration Tests

The project includes automated tests to verify the integration between Foreman and Keycloak:

### Implemented Tests

1. **Keycloak Health Check**
2. **Realm Configuration**
3. **Client Configuration**
4. **User Authentication**
5. **Role Verification**
6. **Foreman SSO Endpoint**
7. **Session Management**
8. **Logout Functionality**

See the playbook and test script for details on each test.

### Running Tests

```bash
ansible-playbook -i inventory.yml test_integration.yml
cat /tmp/foreman_keycloak_test_report.html
```

---

## How to Fork this Repository

If you want to use GitHub Actions in your own account, you need to fork this repository:

1. Go to the original repository: [https://github.com/enemy100/foreman-sso-setup](https://github.com/enemy100/foreman-sso-setup)
2. Click the **Fork** button (top right of the page).
3. Select your personal account (or organization) as the destination.
4. Wait for GitHub to create the fork. You will be redirected to your new fork at `https://github.com/YOUR_USERNAME/foreman-sso-setup`.
5. Now you can clone, configure secrets, and use GitHub Actions in your own fork!

---

## Automated Installation with GitHub Actions

This project includes a GitHub Actions workflow for automated SSO deployment.

### 1. Prepare SSH Key and GitHub Secrets
If you don't have an SSH key for GitHub Actions to access your server, generate one:
```bash
ssh-keygen -t rsa -b 4096 -C "github-actions"
```
Add the **public key** to your server's `~/.ssh/authorized_keys`.

In your repository, go to **Settings > Secrets and variables > Actions** and add:
- `SSH_PRIVATE_KEY`: (content of the private key you just generated)
- `KEYCLOAK_ADMIN_PASSWORD`: (your chosen Keycloak admin password)

### 2. Using GitHub Actions (for any user)

Follow these steps:

1. **Fork this repository** to your own GitHub account (see above).
2. **Add the required secrets** in your fork:
   - Go to `Settings > Secrets and variables > Actions`
   - Add `SSH_PRIVATE_KEY` and `KEYCLOAK_ADMIN_PASSWORD`
3. **Trigger the workflow**:
   - Go to the `Actions` tab in your fork
   - Select the workflow (e.g., `Deploy SSO`)
   - Click `Run workflow` and fill in the required inputs

> **Note:**  
> The SSH key you provide must have access to the target server.  
> You can only see and use secrets in your own fork, not in the original repository.

### 3. What Happens Next?
- The workflow will:
  - Checkout the repository
  - Set up SSH access to your server
  - Run the Ansible playbook to install and configure Keycloak SSO
  - Run integration tests and show results in the Actions log

### 4. Monitoring and Results
- You can follow the progress in the Actions tab
- If the workflow fails, check the logs for troubleshooting
- On success, your Foreman instance will be SSO-enabled with Keycloak

---

## Security
- Passwords are automatically generated and securely stored
- Configurable password policies
- Brute force protection
- SSL/TLS certificates
- Granular roles and permissions

## Roadmap
- **Monitoring:** Future versions may include automated monitoring integration. For example, integration with [zabbix-iaac](https://github.com/enemy100/zabbix-iaac) to provide full monitoring automation for Foreman and Keycloak environments.
- **Backup and Recovery:** Plans to add automated backup and restore tasks for Keycloak and Foreman configurations and databases.
- **More tests and security hardening:** Additional integration and security tests.

## Contributing
1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Support
For support, open an issue on GitHub or contact the infrastructure team.

