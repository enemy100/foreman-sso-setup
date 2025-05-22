# Foreman SSO Setup with Keycloak

This project provides a step-by-step implementation of Single Sign-On (SSO) for Foreman using Keycloak, with automated deployment through GitHub Actions.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Installation Steps](#installation-steps)
- [GitHub Actions Setup](#github-actions-setup)
- [Manual Installation](#manual-installation)
- [Verification](#verification)
- [Troubleshooting](#troubleshooting)

## Prerequisites

Before starting, ensure you have:
1. A working Foreman installation
2. GitHub account with repository access
3. SSH access to your Foreman server
4. At least 4GB RAM and 10GB disk space available

## Project Structure

```
foreman-sso-setup/
├── .github/
│   └── workflows/          # GitHub Actions workflows
├── ansible/
│   ├── roles/             # Ansible roles
│   │   └── keycloak_setup/
│   ├── playbooks/         # Ansible playbooks
│   └── host_vars/         # Host variables
└── docs/                  # Documentation
```

## Installation Steps

### 1. GitHub Repository Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/enemy100/foreman-sso-setup.git
   cd foreman-sso-setup
   ```

2. Configure GitHub Secrets:
   - Go to your repository settings
   - Navigate to Secrets and Variables > Actions
   - Add the following secrets:
     - `SSH_PRIVATE_KEY`: Your SSH private key for Foreman server access
     - `ANSIBLE_USER`: Username for SSH access
     - `KEYCLOAK_ADMIN_PASSWORD`: Admin password for Keycloak

### 2. GitHub Actions Setup

The project includes a GitHub Actions workflow that automates the SSO setup. To use it:

1. Go to your repository on GitHub
2. Navigate to Actions
3. Select "Deploy SSO" workflow
4. Click "Run workflow"
5. Enter your Foreman server hostname
6. Click "Run workflow"

The workflow will:
- Connect to your Foreman server
- Install Keycloak
- Configure SSO
- Test the integration

### 3. Manual Installation (Alternative)

If you prefer manual installation:

1. Configure variables:
   ```bash
   # Edit host variables
   vim ansible/host_vars/foreman_vars.yml
   ```

2. Run the playbook:
   ```bash
   cd ansible/playbooks
   ansible-playbook -i ../../inventory.yml site.yml
   ```

## Verification

After installation:

1. Access Foreman console
2. Go to Administer > Authentication Sources
3. Verify Keycloak is listed and enabled
4. Try logging in with Keycloak credentials

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Verify SSH key is correct
   - Check server accessibility
   - Verify user permissions

2. **Keycloak Installation Failed**
   - Check Java installation
   - Verify port availability
   - Check system resources

3. **SSO Integration Issues**
   - Verify Foreman configuration
   - Check Keycloak realm settings
   - Verify client configuration

### Logs

Key logs locations:
- Keycloak: `/var/log/keycloak/keycloak.log`
- Foreman: `/var/log/foreman/production.log`

## Security Considerations

1. **Passwords**
   - Change default Keycloak admin password
   - Use strong passwords
   - Rotate secrets regularly

2. **Access Control**
   - Limit SSH access
   - Use firewall rules
   - Enable SSL/TLS

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 