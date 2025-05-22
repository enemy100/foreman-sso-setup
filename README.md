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

## Project Structure

```
foreman-sso-setup/
├── ansible/
│   ├── roles/
│   │   └── keycloak_setup/
│   │       ├── tasks/
│   │       │   ├── main.yml
│   │       │   ├── users.yml
│   │       │   ├── groups.yml
│   │       │   ├── roles.yml
│   │       │   ├── password_policy.yml
│   │       │   └── verify.yml
│   │       └── files/
│   │           └── test_integration.sh
│   ├── playbooks/
│   │   └── test_integration.yml
│   └── host_vars/
│       └── foreman_vars.yml
├── docs/
│   └── foreman-integration.md
└── .github/
    └── workflows/
        └── deploy-sso.yml
```

## Configuration

1. Configure variables in `ansible/host_vars/foreman_vars.yml`:
   ```yaml
   keycloak_version: "21.1.1"
   keycloak_admin_user: "admin"
   keycloak_admin_password: "your-secure-password"
   keycloak_https_port: 8443
   foreman_realm_name: "foreman"
   foreman_client_id: "foreman"
   ```

2. Adjust user, group, and role settings as needed.

## Installation (Manual)

Run the main playbook:
```bash
ansible-playbook -i inventory.yml site.yml
```

## Integration Tests

The project includes automated tests to verify the integration between Foreman and Keycloak:

### Implemented Tests

1. **Keycloak Health Check**
   - Verifies if Keycloak is responding
   - Tests the health check endpoint

2. **Realm Configuration**
   - Verifies if the realm is properly configured
   - Tests the OpenID configuration endpoint

3. **Client Configuration**
   - Verifies if the Foreman client exists
   - Tests client settings

4. **User Authentication**
   - Tests login with a test user
   - Verifies token generation

5. **Role Verification**
   - Verifies if the user has correct roles
   - Tests role mapping

6. **Foreman SSO Endpoint**
   - Tests Foreman authentication endpoint
   - Verifies redirection

7. **Session Management**
   - Tests session creation and validation
   - Verifies access token

8. **Logout Functionality**
   - Tests logout process
   - Verifies token invalidation

### Running Tests

1. Run the test playbook:
   ```bash
   ansible-playbook -i inventory.yml ansible/playbooks/test_integration.yml
   ```

2. Check the generated report:
   ```bash
   cat /tmp/foreman_keycloak_test_report.html
   ```

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

### 2. Trigger the Workflow
- Go to the **Actions** tab in your GitHub repository
- Select the workflow (e.g., `Deploy SSO`)
- Click **Run workflow**
- Fill in any required inputs (e.g., Foreman host, Keycloak version)
- Click **Run workflow**

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

## Monitoring

- Automated health checks
- Detailed logging
- Performance metrics
- Security alerts

## Backup and Recovery

- Automated configuration backups
- Recovery scripts
- Procedure documentation

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Support

For support, open an issue on GitHub or contact the infrastructure team.












