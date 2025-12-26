# Using SOPS with Git

To use SOPS (Secrets OPerationS) with Git, you can set up Git filters to automatically encrypt and decrypt files as they are committed and checked out. This allows you to keep sensitive information secure in your repository while still being able to work with it easily.

## Setting Up Git Filters for SOPS

```sh
git config --local filter.sops.smudge './.githooks/decrypt "%f"'
git config --local filter.sops.clean './.githooks/encrypt "%f"'
git config --local filter.sops.required true
git pull
```
