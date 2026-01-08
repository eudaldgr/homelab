# Ansible

## Vault cheatsheet

```sh
# Set the vault password file environment variable
export ANSIBLE_VAULT_PASSWORD_FILE=.vault_pass
# Create a new vault file
ansible-vault create <filename>
# Edit an existing vault file
ansible-vault edit <filename>
# View the contents of a vault file
ansible-vault view <filename>
# Encrypt an existing file
ansible-vault encrypt <filename>
# Decrypt an existing vault file
ansible-vault decrypt <filename>
# Rekey (change the password) of a vault file
ansible-vault rekey <filename>
# Run a playbook with vault password prompt
ansible-playbook <playbook.yml> --ask-vault-pass
# Run a playbook with vault password file
ansible-playbook <playbook.yml> --vault-password-file <password_file>
```
