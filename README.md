# Project 05 — Automate Package Installation

A safe, repeatable Bash installer for Debian/Ubuntu systems using `apt-get`.

## Features

- Reads package names from a version-controlled file
- Ignores blank lines and comments
- Supports dry-run mode
- Supports optional package-index refresh
- Uses `sudo` automatically when not run as root
- Validates the package file and required tooling
- Fails clearly on invalid input or unsupported hosts

## Usage

```bash
./install.sh --dry-run
sudo ./install.sh --update
./install.sh --package-file packages/ubuntu.txt --dry-run
```

The default package list is `packages/ubuntu.txt`.

## Project Scope

This project intentionally targets Debian/Ubuntu package management rather than pretending to support every Linux distribution through one script. A future extension could add separate installers for `dnf` and `apk`.

## Testing

Run the smoke tests with:

```bash
bash tests/test_install.sh
```

## CI

GitHub Actions runs Bash syntax checks and the smoke test suite on every push and pull request.
