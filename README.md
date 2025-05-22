# Foreman SSO Setup with Keycloak

This project provides a step-by-step implementation of Single Sign-On (SSO) for Foreman using Keycloak, with automated deployment through GitHub Actions.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Keycloak Overview](#keycloak-overview)
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
5. Java 17 or higher installed on the Foreman server

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

## Keycloak Overview

Keycloak is an open-source identity and access management solution. Here's how it works in our setup:

### 1. Keycloak Components

- **Realm**: A security boundary that contains users, roles, and clients
- **Clients**: Applications that can request authentication (Foreman in our case)
- **Users**: End users who will authenticate
- **Roles**: Permissions that can be assigned to users
- **Groups**: Collections of users for easier management

### 2. Keycloak Administration

After installation, access the Keycloak Admin Console:
1. Open `https://your-server:8443/admin`
2. Login with:
   - Username: `admin`
   - Password: `KEYCLOAK_ADMIN_PASSWORD` (set during installation)

### 3. User Management

1. **Create Users**:
   - Go to Users → Add User
   - Fill in required fields (Username, Email, First/Last Name)
   - Set initial password in Credentials tab
   - Enable "Email Verified" if using email verification

2. **Create Groups**:
   - Go to Groups → New
   - Name your group (e.g., "Foreman Users")
   - Add users to groups for easier management

3. **Create Roles**:
   - Go to Roles → Add Role
   - Create roles like:
     - `foreman-admin`
     - `foreman-user`
     - `foreman-viewer`

4. **Assign Roles**:
   - Go to Users → Select User → Role Mappings
   - Assign appropriate roles
   - Or assign roles to groups for automatic inheritance

### 4. Client Configuration

1. **Create Foreman Client**:
   - Go to Clients → Create
   - Client ID: `foreman`
   - Client Protocol: `openid-connect`
   - Root URL: `https://your-foreman-url`

2. **Configure Client Settings**:
   - Access Type: `confidential`
   - Valid Redirect URIs: `https://your-foreman-url/users/auth/keycloak/callback`
   - Web Origins: `https://your-foreman-url`
   - Enable "Standard Flow"

3. **Client Roles**:
   - Go to Clients → foreman → Roles
   - Create roles matching Foreman permissions
   - Map these roles to users/groups

## GitHub Actions Setup

### 1. Generate SSH Key for GitHub Actions

On your Foreman server:
```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -C "github-actions-deploy" -f ~/.ssh/github_actions

# Display public key (add to authorized_keys)
cat ~/.ssh/github_actions.pub >> ~/.ssh/authorized_keys

# Display private key (add to GitHub Secrets)
cat ~/.ssh/github_actions
```

### 2. Configure GitHub Secrets

1. Go to your repository → Settings → Secrets and Variables → Actions
2. Add these secrets:
   - `SSH_PRIVATE_KEY`: The private key generated above
   - `ANSIBLE_USER`: Your SSH username (e.g., root)
   - `KEYCLOAK_ADMIN_PASSWORD`: A secure password for Keycloak admin

### 3. Generate Keycloak Admin Password

```bash
# Generate a secure password
openssl rand -base64 32
```

Use this generated password as your `KEYCLOAK_ADMIN_PASSWORD` in GitHub Secrets.

### 4. Workflow Execution

1. Go to Actions → Deploy SSO
2. Click "Run workflow"
3. Enter parameters:
   - `foreman_host`: Your Foreman server's hostname/IP
   - `keycloak_version`: Keycloak version (default: 21.1.1)

## Installation Steps

### 1. GitHub Repository Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/enemy100/foreman-sso-setup.git
   cd foreman-sso-setup
   ```

2. Follow the GitHub Actions Setup section above to configure secrets

### 2. Manual Installation (Alternative)

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

1. **Test Keycloak Admin Console**:
   ```bash
   # Check Keycloak is running
   curl -k https://localhost:8443/health/ready
   
   # Access admin console
   https://your-server:8443/admin
   ```

2. **Test Foreman SSO**:
   - Access Foreman console
   - Click "Sign in with Keycloak"
   - Verify successful login
   - Check user roles and permissions

3. **Verify User Access**:
   - Log in with different user roles
   - Verify correct permissions
   - Test group-based access

## Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   ```bash
   # Test SSH connection
   ssh -i ~/.ssh/github_actions your-user@your-server
   
   # Check SSH logs
   tail -f /var/log/auth.log
   ```

2. **Keycloak Issues**
   ```bash
   # Check Keycloak status
   systemctl status keycloak
   
   # View Keycloak logs
   tail -f /var/log/keycloak/keycloak.log
   
   # Check Java version
   java -version
   ```

3. **Foreman SSO Issues**
   ```bash
   # Check Foreman logs
   tail -f /var/log/foreman/production.log
   
   # Verify plugin installation
   foreman-rake plugin:list | grep keycloak
   ```

### Logs

Key logs locations:
- Keycloak: `/var/log/keycloak/keycloak.log`
- Foreman: `/var/log/foreman/production.log`
- System: `/var/log/syslog`

## Security Considerations

1. **Passwords**
   - Change default Keycloak admin password
   - Use strong passwords
   - Rotate secrets regularly
   - Enable password policies in Keycloak

2. **Access Control**
   - Limit SSH access
   - Use firewall rules
   - Enable SSL/TLS
   - Configure session timeouts

3. **Monitoring**
   - Set up alerts for failed logins
   - Monitor system resources
   - Track user sessions
   - Log security events

## Contributing

Contributions are welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details. 